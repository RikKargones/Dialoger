extends Node

class_name DialogProcessor

var dialog_dispetcher	= null

var playing 			= false
var logic_result		= false
var dialog_name			= ""
var current_node		= ""
var current_lang		= ""
var dialog_info 		= {}
var current_textures 	= {}
var current_options		= []

var one_shot = false

signal dp_deleted

signal dp_playing(dialog_name)
signal dp_text_changed(person, font, align, text)
signal dp_options_presented(options_array)
signal dp_person_mood_changed(person, align, to_mood)

func is_active():
	return playing

func set_dialog_info(dialog_id : int, start_lang : String, oneshot : bool):
	one_shot = oneshot
	if is_instance_valid(dialog_dispetcher):
		if dialog_id in dialog_dispetcher.dialog_names.values():
			dialog_name = dialog_dispetcher.dialog_names.keys()[dialog_id]
			dialog_info = dialog_dispetcher.dialogs_atlas[dialog_name]
			current_lang = start_lang
		else:
			print_to_panel("ERROR! DialogID not exist in DialogDispetcher database!")
	else:
		end()
		
func change_langluage(lang : String):
	current_lang = lang
	if playing:
		process_current_part()

func print_to_panel(text : String):
	if is_instance_valid(dialog_dispetcher):
		dialog_dispetcher.print_to_panel(text)
		
func pick_option(option_id : int):
	if dialog_name != "":
		process_next_part(option_id)

func set_varible(varible_name : int, value):
	if is_instance_valid(dialog_dispetcher):
		dialog_dispetcher.set_varible(varible_name, value)
	else:
		end()

func start():
	if !is_instance_valid(dialog_dispetcher):
		end()
		return
	
	if dialog_info.size() != 0 && current_lang != "":
		if dialog_info["Start"] != "" && dialog_info["Start"] in dialog_info["Nodes"].keys():
			current_node = dialog_info["Start"]
		else:
			print_to_panel("This dialog ("+ dialog_name + ") doesn't have start node. Dialog not executed.")
			return
		
		process_current_part()
		playing = true
			
		emit_signal("dp_playing", dialog_name)
		print_to_panel("Dialog (" + dialog_name + ") is playing.")
	else:
		print_to_panel(str(dialog_name) + " - dialog information is empty!")

func print_no_dialog_dispetcher_error():
	print("CRITICAL ERROR! DialogDispetcher not seted for DialogProcesser!")

func end():
	if is_instance_valid(dialog_dispetcher):
		dialog_dispetcher.emit_signal("dd_ended", dialog_name)
		print_to_panel("Dialog (" + dialog_name + ") ended.\n---")
		if one_shot:
			emit_signal("dp_deleted")
			queue_free()
	else:
		print_no_dialog_dispetcher_error()
		
	current_textures 	= {}
	current_node 		= ""
	playing 			= false

func check_correction(data : Array):
	if !is_instance_valid(dialog_dispetcher):
		end()
		return false
		
	var statement_str 	= "return_bool( "
	var express			= Expression.new()
	var all_vars		= dialog_dispetcher.get_bool_var_atlas().duplicate(true)
	
	all_vars.merge(dialog_dispetcher.get_int_var_atlas())
	all_vars.merge(dialog_dispetcher.get_str_var_atlas())
	
	for info in data:
		match info[0]:
			"VAR":
				statement_str += form_codelike_string(all_vars[info[1]]) + " " + str(info[2]) + " " + form_codelike_string(info[3]) + " " 
			"NOT":
				statement_str += "! "
			"AND":
				statement_str += "&& "
			"OR":
				statement_str += "|| "
			"BRSO":
				statement_str += "( "
			"BRSC":
				statement_str += ") "
	
	statement_str += ")"
	
	var error = express.parse(statement_str)
	
	if error != OK:
		print_to_panel("LogicError: " + express.get_error_text())
		return false
	else:
		express.execute([], self)
		return logic_result

func create_texture_from_path(path : String) -> ImageTexture:
	var img = Image.new()
	var img_tex = ImageTexture.new()
	img.load(path)
	img_tex.create_from_image(img)
	return img_tex

func return_bool(expression = true):
	logic_result = expression

func form_codelike_string(varible):
	var final_string = ""
	match typeof(varible):
		TYPE_ARRAY:
			final_string += "["
			for part in varible:
				if !final_string.ends_with("["): final_string += ", "
				final_string += form_codelike_string(part)
			final_string += "]"
		TYPE_DICTIONARY:
			final_string += "{"
			for key in varible.keys():
				if !final_string.ends_with("{"): final_string += ", "
				final_string += "\"" + key + "\" : " + form_codelike_string(varible[key])
			final_string += "}"
		TYPE_STRING:
			final_string += "\"" + varible.replace("\n", "\\n") + "\""	
		TYPE_VECTOR2:
			final_string += "Vector2" + str(varible)
		TYPE_BOOL:
			if varible: final_string += "true"
			else: final_string += "false"
		_:
			final_string += str(varible)
		
	return final_string

func gather_next_node(start_node, check_port = -1):
	var connected_node = ""
	
	for con in dialog_info["Connections"]:
		if con["from"] == start_node:
			if check_port > -1 && con["from_port"] == check_port:
				connected_node = con["to"]
				break
			elif check_port == -1:
				connected_node = con["to"]
				break
			
	return connected_node

func process_next_part(check_port = -1):
	if !playing: return
	current_node = gather_next_node(current_node, check_port)
	process_current_part()

func process_current_part():
	if !is_instance_valid(dialog_dispetcher):
		end()
		return
	
	if current_node == "":
		end()
	else:
		var node_info = dialog_info["Nodes"][current_node]
		var info_print = ""
		var opt_type = false
		
		match node_info["Type"]:
			"Options":
				var data = node_info["Data"]
				var output_arr = []
				
				for info_idx in data["Words"][1][current_lang][1].size():
					output_arr.append([data["Words"][1][current_lang][1][info_idx], check_correction(data["Words"][2][info_idx])])
					
				emit_signal("dp_options_presented", output_arr)
				opt_type = true
				continue
			"Options", "Replic":
				var font 		= dialog_dispetcher.get_font_by_name(dialog_dispetcher.lang_atlas[current_lang])
				var data 		= node_info["Data"]
				var mood_name	= data["Mood"]
				var words		= ""
				var person_name = ""
				
				if opt_type:
					words = data["Words"][1][current_lang][0]
				else:
					words = data["Words"][1][current_lang]
					
				if data["Words"][0] in dialog_dispetcher.font_atlas.keys():
					font = dialog_dispetcher.get_font_by_name(data["Words"][0])
				
				#{Name_id : {Names : [lang_name : name], Fonts : [lang_name : font_name], Moods : {Mood_Name : Texture}}}
				
				if data["Person"] in dialog_dispetcher.persons_atlas.keys():
					var person_info = dialog_dispetcher.persons_atlas[data["Person"]]
					person_name = person_info["Names"][current_lang]
					
					if !data["Words"][0] in dialog_dispetcher.font_atlas.keys():
						font = dialog_dispetcher.get_font_by_name(person_info["Fonts"][current_lang])
					
					if mood_name == "<Empty>":
						emit_signal("dp_person_mood_changed", person_name, data["Align"], null)
						current_textures[data["Person"]] = [mood_name, data["Align"]]
					elif mood_name in person_info["Moods"].keys():
						if data["Person"] in current_textures.keys():
							var compare_data = current_textures[data["Person"]]
							if compare_data[0] != mood_name || compare_data[1] != data["Align"]:
								emit_signal("dp_person_mood_changed", person_name, data["Align"], create_texture_from_path(person_info["Moods"][mood_name]))
								current_textures[data["Person"]] = [mood_name, data["Align"]]
						else:
							emit_signal("dp_person_mood_changed", person_name, data["Align"], create_texture_from_path(person_info["Moods"][mood_name]))
							current_textures[data["Person"]] = [mood_name, data["Align"]]
					elif data["Person"] in current_textures.keys():
						var old_mood = current_textures[data["Person"]][0]
						if old_mood in person_info["Moods"].keys():
							emit_signal("dp_person_mood_changed", person_name, data["Align"], create_texture_from_path(person_info["Moods"][old_mood]))
				
				emit_signal("dp_text_changed", person_name, font, data["Align"], words)
			"Branch":
				var branches = node_info["Data"]["Options"]
				var choices = []
				var choise_num = -1
				
				for branch in branches:
					choices.append(check_correction(branch["Logic"]))
				
				choise_num = choices.find(true)
				
				process_next_part(choise_num)
				
				if choise_num != -1:
					info_print = "Dialog branched to: " + str(choise_num + 1) + " branch"
					if branches[choise_num]["Name"].strip_edges() != "":
						info_print += " (" + branches[choise_num]["Name"] + ")."
					else:
						info_print += "."
					
					if choices.find(true, choise_num + 1) != -1:
						info_print += " WARNING! More then 1 branches meets their statements! First of them picked."
				
				elif choices.size() != 0:
					info_print = "WARNING! None of branches meets their statements! First branch will be picked."
				
			"Varible":
				var varible_name 	= node_info["Data"]["Varible"]
				var new_data		= null
				var bool_atlas 		= dialog_dispetcher.get_bool_var_atlas()
				var int_atlas	 	= dialog_dispetcher.get_int_var_atlas()
				var str_atlas 		= dialog_dispetcher.get_str_var_atlas()
				
				if varible_name in bool_atlas.keys():
					var bool_set = node_info["Data"]["BoolSettings"]
					
					info_print = "Bool varible (" + varible_name + ") has changed from " + str(bool_atlas[varible_name])
					
					if bool_set[0]: new_data = !bool_atlas[varible_name]
					elif bool_set[1]: new_data = bool_set[2]
					
					info_print += " to " + str(bool_atlas[varible_name]) + "."
						
				elif varible_name in int_atlas.keys():
					var int_set = node_info["Data"]["IntSettings"]
					
					info_print = "Integer varible (" + varible_name + ") has changed from " + str(int_atlas[varible_name])
					
					if int_set[0] || int_set[1]: new_data = int_atlas[varible_name] + int_set[2] * (-1*int(int_set[0]))
					elif int_set[3]: new_data = int_set[4]
					
					info_print += " to " + str(int_atlas[varible_name]) + "."
					
				elif varible_name in str_atlas.keys():
					var str_set = node_info["Data"]["StringSettings"]
					
					info_print = "String varible (" + varible_name + ") has changed from " + str(str_atlas[varible_name]) + " to " + str(str_set[0]) + "."
					
					new_data = str_set[0]
						
				elif dialog_dispetcher.has_signal(varible_name):
					var sig_set = node_info["Data"]["SignalSettings"]
					
					info_print = "Signal \"" + varible_name + "\" was emitted with " + str(sig_set[0]) + " argument."
					
					dialog_dispetcher.emit_signal(varible_name, sig_set[0])
				
				process_next_part()
				dialog_dispetcher.set_varible_by_name(varible_name, new_data)
			_:
				process_next_part()
		
		if info_print != "": print_to_panel(info_print)

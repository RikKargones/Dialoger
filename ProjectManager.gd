extends Node

var fonts_atlas 	= {}
var persons_atlas 	= {}
var dialog_atlas	= {}
var varibles_atlas	= {}
var font_lang_atlas	= {"English" : [Translation.new(), ""]}

var atlases = {}

var project_name			= ""
var project_folder			= ""
var project_create_date		= Time.get_date_dict_from_system()
var project_create_time		= Time.get_time_string_from_system()
var project_create_version	= Defaluts.version
var project_unsaved			= false

var person_collector_func 	: FuncRef = null
var varibles_collector_func : FuncRef = null
var langs_collector_func	: FuncRef = null
var dialogs_collector_func	: FuncRef = null
var fonts_collector_func	: FuncRef = null

signal fonts_updated
signal persons_updated
signal dialogs_updated
signal varibles_updated
signal langs_updated

signal clear_project
	
func clear_project():
	project_name 	= ""
	project_folder 	= ""
	
	fonts_atlas 	= {}
	persons_atlas 	= {}
	dialog_atlas 	= {}
	varibles_atlas 	= {}
	font_lang_atlas	= {"English" : ["", Translation.new()]}
	
	emit_signal("clear_project")
	
	project_unsaved = false

func set_persons_collector(callable : FuncRef):
	person_collector_func = callable

func set_varibles_collector(callable : FuncRef):
	varibles_collector_func = callable

func set_langs_collector(callable : FuncRef):
	langs_collector_func = callable
	
func set_dialogs_collector(callable : FuncRef):
	dialogs_collector_func = callable
	
func set_fonts_collector(callable : FuncRef):
	fonts_collector_func = callable

func collect_project_info():
	fonts_collector_func.call_func()
	langs_collector_func.call_func()
	varibles_collector_func.call_func()
	person_collector_func.call_func()
	dialogs_collector_func.call_func()

func set_atlas_key(key : String, data : Dictionary):
	atlases[key] = data

func has_key_in_atlas(key : String) -> bool:
	return key in atlases.keys()

func get_atlas_key(key : String) -> Dictionary:
	return atlases[key]

func update_fonts_atlas(new_fonts_atlas : Dictionary):
	project_unsaved = !data_is_same(fonts_atlas, new_fonts_atlas)
	fonts_atlas = new_fonts_atlas
	emit_signal("fonts_updated")
	#print(Time.get_time_string_from_system() + ": Updated fonts")
	
func update_persons_atlas(new_persons : Dictionary):
	project_unsaved = !data_is_same(persons_atlas, new_persons)
	persons_atlas = new_persons
	emit_signal("persons_updated")
	#print(Time.get_time_string_from_system() + ": Updated persons")

func update_dialog_atlas(new_dialogs : Dictionary):
	project_unsaved = !data_is_same(dialog_atlas, new_dialogs)
	dialog_atlas = new_dialogs
	emit_signal("dialogs_updated")
	
func update_dialog_in_atlas(dialog_name : String, dialog_info : Dictionary):
	project_unsaved = !data_is_same(dialog_atlas[dialog_name], dialog_info)
	dialog_atlas[dialog_name] = dialog_info
	emit_signal("dialogs_updated")
	
func update_varibles_atlas(new_varibles : Dictionary):
	project_unsaved = !data_is_same(varibles_atlas, new_varibles)
	varibles_atlas = new_varibles
	emit_signal("varibles_updated")

func data_is_same(old_data, new_data) -> bool:
	if typeof(old_data) != typeof(new_data): return false
	elif old_data is Dictionary && new_data.hash() != old_data.hash(): return false
	elif old_data != new_data: return false
	
	return true

func is_font_in_atlas(font_name : String):
	return font_name in fonts_atlas.keys()
	
func is_person_in_atlas(person_name : String):
	return person_name in persons_atlas.keys()
	
func is_mood_in_atlas(person_name : String, mood_name : String):
	return is_person_in_atlas(person_name) && mood_name in persons_atlas[person_name]["Moods"].keys()
	
func is_dialog_in_atlas(dialog_name : String):
	return dialog_name in dialog_atlas.keys()

func is_varible_in_atlas(varible_name : String):
	return varible_name in varibles_atlas.keys()

func is_lang_in_atlas(lang_name : String):
	return lang_name in font_lang_atlas.keys()
	
func is_lang_has_key(lang_name : String, key : String):
	return lang_name in font_lang_atlas.keys() && key in font_lang_atlas[lang_name][0].get_message_list()

func get_font_by_name(font_name : String) -> DynamicFont:
	return fonts_atlas[font_name][0]

func get_person_by_name(person_name : String) -> Dictionary:
	return persons_atlas[person_name]
	
func get_mood_by_name(person_name : String, mood_name : String):
	return persons_atlas[person_name]["Moods"][mood_name][0]
	
func get_dialog_by_name(dialog_name : String) -> Dictionary:
	return dialog_atlas[dialog_name]

func get_lang_font_by_name(lang_name : String) -> String:
	return font_lang_atlas[lang_name][1]

func get_lang_translation(lang_name : String, key : String) -> String:
	var translation : Translation = font_lang_atlas[lang_name][0]
	return translation.get_message(key)

func export_data(args = ["user://TestExport", false]):
	var path_to_save = args[0]
	var non_res = args[1]
	
	collect_project_info()
	project_unsaved = false
	
	var dir_manager 		= Directory.new()	
	var main_path			= path_to_save.trim_suffix("/") + "/Dialogs"
	var export_sum : float 	= 7.0
	var export_step 		= 0

	export_sum += fonts_atlas.size()
	export_sum += persons_atlas.size()
	export_sum += font_lang_atlas.size()
	export_sum += varibles_atlas.size()
	export_sum += dialog_atlas.size()
	export_sum += FileManger.files_list.size()
	
	export_step = 100/export_sum
	
	Global.call_deferred("start_export_status", "Creating main folder in " + main_path + "...")
	
	if dir_manager.dir_exists(main_path):
		FileManger.delete_folder_recursive(main_path)
	
	dir_manager.make_dir_recursive(main_path)
	
	if dir_manager.dir_exists(main_path):
		Global.update_export_status(export_step, "Exporting external resourses...")
		var ext_res_list = FileManger.export_temp_files(main_path, !non_res)
		var file_handler = File.new()
		Global.call_deferred("update_export_status", export_step * FileManger.files_list.size(), "Exporting empty DialogDispetcher...")
		
		var dir_error = dir_manager.copy("res://DialogDispetcher/DialogDispetcher.gd", main_path + "/DialogDispetcher.gd")
		var file_error = file_handler.open(main_path + "/DialogDispetcher.gd", File.READ)
		
		if dir_error == OK && file_error == OK:
			var dd_code = file_handler.get_as_text()
			var font_dict = {}
			var fonts_names = "enum fonts_names	{\n"
			file_handler.close()
			
			export_sum += export_step
			dir_manager.make_dir_recursive(main_path + "/DynamicFonts")
			
			for font in fonts_atlas.keys():
				Global.update_export_status(export_step, "Exporting fonts (" + font + ")...")
				var file_path = main_path + "/DynamicFonts/" + font + ".tres"
				
				if !fonts_names.ends_with("{\n"): fonts_names += ",\n"
				fonts_names += font
				
				ResourceSaver.save(file_path, fonts_atlas[font][0], ResourceSaver.FLAG_BUNDLE_RESOURCES)
				
				if non_res: font_dict[font] = main_path + "/DynamicFonts/" + font + ".tres"
				else: font_dict[font] = "res://Dialogs/DynamicFonts/" + font + ".tres"
				
				if file_handler.open(file_path, File.READ) == OK:
					var file_text = file_handler.get_as_text()
					file_handler.close()
					
					var font_path_text : String = "font_path = \"" + ext_res_list[fonts_atlas[font][1]] + "/" + fonts_atlas[font][1] + "\"" 
					file_text = find_and_replace_line("font_path", font_path_text, file_text)
					
					if file_handler.open(file_path, File.WRITE_READ) == OK: file_handler.store_string(file_text)
					else: print("Can't resave font scene file...")
				else:
					print("ERROR! Cannot open alredy saved file! Path to resourse not changed.")
					
				file_handler.close()
			
			fonts_names += "\n}"
			
			var langs_names		= "enum langs_names {\n"
			
			for lang in font_lang_atlas.keys():
				Global.call_deferred("update_export_status", export_step, "Exporting langs-font corelation (" + lang + ")...")
				if !langs_names.ends_with("{\n"): langs_names += ",\n"
				langs_names += lang
			
			langs_names += "\n}"
			
			var person_dict = {}
			#{Name_id : {Names : {lang_name : name}, Fonts : {lang_name : font_name}, Moods : {Mood_Name : Texture}}}
			for person in persons_atlas.keys():
				Global.call_deferred("update_export_status", export_step, "Exporting person (" + person + ")...")
				dir_manager.make_dir_recursive(main_path + "/Persons/" + person)
				
				person_dict[person] = {"Names" : persons_atlas[person]["Names"], "Fonts" : persons_atlas[person]["Fonts"], "Moods" : {}}
				
				for mood in persons_atlas[person]["Moods"].keys():
					Global.call_deferred("update_export_status", export_step, "Exporting person (" + person + ") mood (" + mood + ")...")
					var mood_info = persons_atlas[person]["Moods"][mood]
					person_dict[person]["Moods"][mood] = ext_res_list[mood_info[1]] + "/" + mood_info[1]
			var signals_atlas_text		= ""
			
			var bool_path 	= {}
			var int_path	= {}
			var string_path	= {}
			
			var varible_names			= "enum varible_names {\n"
			
			for varible in varibles_atlas.keys():
				if varibles_atlas[varible][0] != "Signal":
					if !varible_names.ends_with("{\n"): varible_names += ",\n"
					varible_names += varible
				
				match varibles_atlas[varible][0]:
					"Bool":
						bool_path[varible] = varibles_atlas[varible][1]
					"Integer":
						int_path[varible] = varibles_atlas[varible][1]
					"String":
						string_path[varible] = varibles_atlas[varible][1]
					"Signal":
						signals_atlas_text += "signal " + varible + "\n"
						
			varible_names			+= "\n}"
			
			Global.call_deferred("update_export_status", export_step, "Exporting dialogs...")
			
			var dialog_names		= "enum dialog_names {\n"
			var dialog_dict		= {}
			
			for dialog in dialog_atlas.keys():
				if !dialog_names.ends_with("{\n"): 		dialog_names += ",\n"
				dialog_names 		+= dialog
				
				dialog_dict[dialog] = {}
				
				for key in dialog_atlas[dialog].keys():
					if key == "Selections": continue
					dialog_dict[dialog][key] = dialog_atlas[dialog][key]
			dialog_names += "\n}"
			
			Global.call_deferred("update_export_status", export_step, "Making database file...")
			
			if file_handler.open(main_path + "/DialogDatabase.ddb", File.WRITE) == OK:
				file_handler.store_var(font_dict)
				file_handler.store_var(font_lang_atlas)
				file_handler.store_var(person_dict)
				file_handler.store_var(bool_path)
				file_handler.store_var(int_path)
				file_handler.store_var(string_path)
				file_handler.store_var(dialog_dict)
			else:
				print("ERROR! Can't create database file!")
				
			file_handler.close()
			
			Global.call_deferred("update_export_status", export_step, "Rewriting code in exported DialogDispetcher...")
			
			dd_code = find_and_replace_line("enum varible_names", varible_names, dd_code)
			dd_code = find_and_replace_line("enum dialog_names", dialog_names, dd_code)
			dd_code = find_and_replace_line("enum langs_names", langs_names, dd_code)
			dd_code = find_and_replace_line("enum fonts_names", fonts_names, dd_code)
			dd_code = find_and_replace_line("const database_path", "const database_path = \"" + main_path + "/DialogDatabase.ddb\"", dd_code)
			dd_code = find_and_replace_line("#С_SIGNALS_EXPORT_MARK", signals_atlas_text, dd_code)
			
			if file_handler.open(main_path + "/DialogDispetcher.gd", File.WRITE_READ) == OK:
				file_handler.store_string(dd_code)
			else:
				Global.popup_error("Can't open DialogDispetcher. Enums and signals not writed.")
			
		file_handler.close()
		
		Global.call_deferred("end_export_status")

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

func find_and_replace_line(substr : String, by : String, text : String):
	var pos = text.find(substr)
	var line = ""
	
	if pos != -1:
		line = text.substr(pos).split("\n", true, 1)[0]
		text = text.replace(line, by)

	return text
		
func get_all_fonts() -> Dictionary:
	return fonts_atlas
	#Fonts structure:
	#{font_name : [font_id_in_godot, temp_file], ...}

func get_all_persons() -> Dictionary:
	return persons_atlas
	#Persons structure:
	#{Name_id : {Names : [lang_name : name], Fonts : [lang_name : font_name], Moods : {Mood_Name : Texture}}}
	
func get_all_dialogs() -> Dictionary:
	return dialog_atlas
	#Dialogs structure:
	#{Dialog_name : {Position : №_in_Dia, Type : element_type, Data : {...}}

func get_all_varibles() -> Dictionary:
	return varibles_atlas
	#Varibles structure
	#{VarName : [Type, Value]}
	
func get_all_langs() -> Dictionary:
	return font_lang_atlas
	#Structure
	#{LangName : FontName}

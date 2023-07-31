extends DialogBase

class_name Replick

var old_text		= ""

var old_cursor_c 	= 0
var old_cursor_l 	= 0
var on_text_filed	= false

var demo_textures	= {"Textures" : [], "Nodes" : []}

onready var dialog_name				= $List/BottomSettings/Replick/Name
onready var words_node				= $List/BottomSettings/Replick/Words
onready var words_panel				= $List/BottomSettings/Replick/Anchor

onready var up_panel				= $List/UpSettings
onready var bottom_panel			= $List/BottomSettings

onready var name_changer 			= $List/UpSettings/NameChoose
onready var demo_image				= $List/BottomSettings/Texture/Position/Shower/Panel/Image
onready var demo_image_positioner 	= $List/BottomSettings/Texture/Position
onready var demo_image_selector		= $List/BottomSettings/Texture/SelectVariants

onready var font_chooser 			= $List/UpSettings/FontChoose
onready var align_chooser			= $List/UpSettings/Align
onready var settings_counter		= $List/UpSettings/Counter
onready var place_label				= $List/UpSettings/PlaceLabel
onready var align_shower			= $List/BottomSettings/Texture/Position/Shower
onready var mood_chooser 			= $List/BottomSettings/Texture/Mood/MoodChoose

onready var short_info				= $List/ShortInfo
onready var short_name				= $List/ShortInfo/Name
onready var short_mood				= $List/ShortInfo/Mood
onready var short_info_counter		= $List/ShortInfo/Counter

func _ready():
	parent_class_instansing()
		
	on_minimaze()
	update_dependesy()
	words_node.text = ""
	ProjectManager.connect("persons_updated", self, "update_dependesy")	
	name_changer.connect("item_selected", self, "_on_NameChoose_item_selected")
	words_node.connect("text_changed", self, "_on_Words_text_changed")
	on_ready_extend()

func on_ready_extend():
	pass

func _physics_process(delta):
	match align_chooser.selected:
		Global.DialogePictureAligment.Right:
			align_shower.alignment_horizontal = AspectRatioContainer.ALIGN_END
		Global.DialogePictureAligment.Center:
			align_shower.alignment_horizontal = AspectRatioContainer.ALIGN_CENTER
		_:
			align_shower.alignment_horizontal = AspectRatioContainer.ALIGN_BEGIN
			
	words_node.set("custom_fonts/font", font_chooser.get_current_font())
	dialog_name.set("custom_fonts/font", font_chooser.get_current_font())
	short_name.set("custom_fonts/font", font_chooser.get_current_font())
	short_mood.set("custom_fonts/font", font_chooser.get_current_font())
	
	short_name.text 	= "Кто: " + name_changer.text + " - Позиция: " + str(get_position_in_parent() + 1)
	short_mood.text 	= "Эмоция: " + mood_chooser.text
	place_label.text 	= "Позиция: " + str(get_position_in_parent() + 1)
	
	var font 			= words_node.get_font("font")
	var total_height 	= 0
	
	for ln in words_node.get_line_count():
		total_height += font.get_height()
		for i in words_node.get_line_wrap_count(ln):
			total_height += font.get_height()
	
	total_height += font.get_height() * 2
	
	words_node.rect_min_size.y = total_height 

func set_lang_variant(info):
	words_node.text = info
	
func get_lang_variant():
	return words_node.text
	
func get_empty_lang_variant():
	return ""
	
func update_on_lang_change():
	update_dependesy()
	
func check_map_popup_needness():
	return !Rect2(Vector2(), words_node.rect_size).has_point(words_node.get_local_mouse_position())

func get_custom_replic_settings() -> Dictionary:
	var data_dict = {}
	
	data_dict["Person"] = name_changer.text
	data_dict["Align"] 	= align_chooser.selected
	data_dict["Mood"]	= mood_chooser.text
	data_dict["Words"]	= [font_chooser.text, lang_variants.get_all_variants()]
	
	return data_dict

func set_custom_settings_from_dict(data : Dictionary):
	for info_name in data.keys():
		var info = data[info_name]
		
		match info_name:
			"Font":
				font_chooser.update_font_list()
				for idx in font_chooser.get_item_count():
					if info == font_chooser.get_item_text(idx):
						font_chooser.select(idx)
						break
			"Person":
				for idx in name_changer.get_item_count():
					if info == name_changer.get_item_text(idx):
						name_changer.select(idx)
						break
				update_moods(name_changer.text)
			"Align":
				align_chooser.select(info)
			"Mood":
				for idx in mood_chooser.get_item_count():
					if info == mood_chooser.get_item_text(idx):
						mood_chooser.select(idx)
						break
			"Words":
				for idx in font_chooser.get_item_count():
					if info[0] == font_chooser.get_item_text(idx):
						font_chooser.select(idx)
						break
						
				lang_variants.set_all_variants(info[1])
				
	update_dependesy()

func on_minimaze():
	up_panel.visible				= !hide_settings
	bottom_panel.visible			= !hide_settings
	short_info.visible				= hide_settings
	
	demo_image_positioner.visible 	= !minimaze_settings
	name_changer.clip_text 			= minimaze_settings
	font_chooser.clip_text 			= minimaze_settings
	mood_chooser.clip_text 			= minimaze_settings
	align_chooser.clip_text			= minimaze_settings
	
	_on_Words_text_changed()
	
func update_dependesy():
	name_changer.update_names()
	update_moods(name_changer.text)
	update_font_placeholders()
	update_demo_image()

func update_moods(person_name : String):
	var list = ["<Previous>", "<Empty>"]
	
	if ProjectManager.is_person_in_atlas(person_name):
		list.append_array(ProjectManager.get_person_by_name(person_name)["Moods"].keys())
	
	Global.update_selector(mood_chooser, list)

func update_font_placeholders():
	var current_lang = lang_variants.get_current_lang()
	dialog_name.text = name_changer.text + ":"
	
	if name_changer.text == name_changer.get_placeholder() && ProjectManager.is_lang_in_atlas(current_lang):
		font_chooser.set_def_placeholder()
		current_lang = lang_variants.get_current_lang()
		var font_name = ProjectManager.get_lang_font_by_name(current_lang)
		
		if ProjectManager.is_font_in_atlas(font_name):
			font_chooser.set_def_placeholder(font_chooser.def_placeholder, ProjectManager.get_font_by_name(font_name))
	
	elif ProjectManager.is_person_in_atlas(name_changer.text):
		var person = ProjectManager.get_person_by_name(name_changer.text)
		var person_font_name = person["Fonts"][current_lang]
		
		if ProjectManager.is_font_in_atlas(person_font_name):
			font_chooser.set_def_placeholder("<Персонажа>", ProjectManager.get_font_by_name(person_font_name))
		elif ProjectManager.is_lang_in_atlas(current_lang) && ProjectManager.is_font_in_atlas(ProjectManager.get_lang_font_by_name(current_lang)):
			font_chooser.set_def_placeholder("<Персонажа>", ProjectManager.get_font_by_name(ProjectManager.get_lang_font_by_name(current_lang)))
		else:
			font_chooser.set_def_placeholder("<Персонажа>", null)
			
		dialog_name.text = person["Names"][lang_variants.get_current_lang()] + ":"
			
	else:
		font_chooser.set_def_placeholder()

func update_demo_image():
	if ProjectManager.is_mood_in_atlas(name_changer.text, mood_chooser.text):
		demo_image.texture = ProjectManager.get_mood_by_name(name_changer.text, mood_chooser.text)
		demo_textures = {"Textures":[demo_image.texture], "Nodes":[name]}
		demo_image_selector.visible = false
	elif ProjectManager.is_person_in_atlas(name_changer.text) && mood_chooser.selected < 1:
		var dia_info = get_current_dialog_info()
		
		if dia_info == {}:
			demo_textures = {"Textures":[null], "Nodes":[name]}
			demo_image_selector.visible = false
		elif "Start" in dia_info.keys() && dia_info["Start"] == name:
			demo_textures = {"Textures":[null], "Nodes":[name]}
			demo_image_selector.visible = false
		elif !("Nodes" in dia_info.keys() && "Connections" in dia_info.keys()):
			demo_textures = {"Textures":[null], "Nodes":[name]}
			demo_image_selector.visible = false
		else:
			demo_textures = get_texture_from_prev_replick(dia_info, name)
			
			if demo_textures["Textures"].size() == 0:
				demo_textures = {"Textures":[null], "Nodes":[name]}
		
		if demo_textures["Textures"].size() < 2:
			demo_image.texture = demo_textures["Textures"][0]
			demo_image_selector.visible = false
		else:
			var vars = []
			
			for nm in demo_textures["Textures"].size():
				vars.append("Var - " + str(nm + 1))
			
			Global.update_selector(demo_image_selector, vars, true)
			if demo_image_selector.selected == -1: demo_image_selector.select(0)
			demo_image.texture = demo_textures["Textures"][demo_image_selector.selected]
			demo_image_selector.visible = true
	else:
		demo_textures = {"Textures":[null], "Nodes":[name]}
		demo_image.texture = null
		demo_image_selector.visible = false

func get_texture_from_prev_replick(dialog_info : Dictionary, from_who):
	var cur_check 		= [from_who]
	var output_textures = {"Textures" : [], "Nodes" : []}
	
	cur_check = find_prev_in_connections(dialog_info["Connections"], from_who)
	
	if cur_check.size() == 0: return output_textures
	
	if name in cur_check: #Prevents from looping
		if cur_check.size() == 1: return output_textures
		else: cur_check.erase(name)
	
	for node in cur_check:	
		if node in dialog_info["Nodes"].keys():
			var node_info = dialog_info["Nodes"][node]
			
			if !node_info["Type"] in [Global.DialogType.keys()[Global.DialogType.Replic], Global.DialogType.keys()[Global.DialogType.Options]]:
				if node == dialog_info["Start"]: continue
				else: output_textures = append_texture_dict(output_textures, dialog_info, node)
			
			elif node_info["Data"]["Person"] == name_changer.text:
				if node_info["Data"]["Mood"] == mood_chooser.get_item_text(0):
					if node == dialog_info["Start"]: continue
					else: output_textures = append_texture_dict(output_textures, dialog_info, node)
				elif ProjectManager.is_mood_in_atlas(name_changer.text, node_info["Data"]["Mood"]):
					output_textures["Textures"].append(ProjectManager.get_mood_by_name(name_changer.text, node_info["Data"]["Mood"]))
					output_textures["Nodes"].append(node)
				else:
					output_textures["Textures"].append(null)
					output_textures["Nodes"].append(node)
			else:
				output_textures = append_texture_dict(output_textures, dialog_info, node)
			
	return output_textures

func find_prev_in_connections(con_info : Array, from_who : String):
	var all_cons = []
	for con in con_info:
		if con["to"] == from_who:
			all_cons.append(con["from"])
	return all_cons

func append_texture_dict(tex_dict : Dictionary, dia_info : Dictionary, node : String):
	var other_dict = get_texture_from_prev_replick(dia_info, node)
	tex_dict["Textures"].append_array(other_dict["Textures"])
	tex_dict["Nodes"].append_array(other_dict["Nodes"])
	return tex_dict

func _on_NameChoose_item_selected(index):
	if ProjectManager.is_person_in_atlas(name_changer.get_item_text(index)):
		var person = ProjectManager.get_person_by_name(name_changer.get_item_text(index))
		for align in align_chooser.get_item_count():
			if align_chooser.get_item_text(align) == person["Align"]:
				align_chooser.select(align)
				return
	
	align_chooser.select(1)

#func _on_MoodChoose_item_selected(index):
#	update_demo_image()

func _on_Words_text_changed():
	old_cursor_c = words_node.cursor_get_column() - (words_node.text.length() - old_text.length())
	old_cursor_l = words_node.cursor_get_line()
	
	if Defaluts.is_text_can_be_replic(words_node.text):
		old_text = words_node.text
		lang_variants.save_info()
	else:
		words_node.text = old_text
		words_node.cursor_set_line(old_cursor_l)
		words_node.cursor_set_column(old_cursor_c)
	
	var symbols 		= "Symbols: " + str(words_node.text.length())
	var lines			= "Lines: " + str(words_node.text.count("\n") + 1)
	
	settings_counter.text 	= symbols + " - " + lines
	short_info_counter.text = symbols + " - " + lines
	
	var best_size = 0
	
	for line in words_node.text.split("\n"):
		var string_size = words_node.get_font("font").get_string_size(line).x
		if best_size < string_size:
			best_size = string_size
	
	words_node.rect_min_size.x = best_size + 50

func get_translation_info(lang : String) -> Dictionary:
	return {"Nodes" : [words_panel], "Texts" : [lang_variants.get_variant(lang)]}

func words_mouse_entered():
	emit_signal("translation_need", self, true)
	
func words_mouse_exited():
	emit_signal("translation_need", self, false)

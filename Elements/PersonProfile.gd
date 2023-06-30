extends MarginContainer

var lang_manager = LangManager.new()

onready var font_choose 	= $Moods/Settings/FontChoose
onready var lang_choose		= $Moods/Settings/LangChangeBt
onready var align_choose	= $Moods/Settings/Align
onready var person_name 	= $Moods/Settings/DialogName
onready var moods			= $Moods/Moods/Scroll/Grid
onready var pck_mood		= preload("res://Elements/Mood.tscn")

func _ready():
	lang_manager.set_funcs(self, "set_from_lang", "get_from_lang", "get_lang_empty")

func set_from_lang(info):
	person_name.text = info[0]
	
	font_choose.select(0)
	
	for idx in font_choose.get_item_count():
		if font_choose.get_item_text(idx) == info[1]:
			font_choose.select(idx)
			break
	
	if ProjectManager.is_font_in_atlas(lang_manager.get_font_from_lang()):
		font_choose.set_def_placeholder(font_choose.def_placeholder, ProjectManager.get_font_by_name(lang_manager.get_font_from_lang()))
	else:
		font_choose.set_def_placeholder()

func get_from_lang():
	return [person_name.text, font_choose.get_item_text(font_choose.selected)]
	
func get_lang_empty():
	return [name,""]

func set_person_info(array : Array):
	var atlas 			= array[1]
	var lang_variants 	= {}
	
	name = array[0]
	
	for lang_name in atlas["Names"].keys():
		lang_variants[lang_name] = [atlas["Names"][lang_name], atlas["Fonts"][lang_name]]
	
	lang_manager.set_all_variants(lang_variants)
	
	for id in align_choose.get_item_count():
		if align_choose.get_item_text(id) == atlas["Align"]:
			align_choose.select(id)
	
	for mood in atlas["Moods"].keys():
		mood_texture_picked(atlas["Moods"][mood])
		moods.get_children()[moods.get_child_count() - 1].set_mood_name(mood)

func get_person_info() -> Array:
	var atlas 		= {}
	var namesfonts	= lang_manager.get_all_variants()
	
	atlas["Names"] = {}
	atlas["Fonts"] = {}
	atlas["Moods"] = {}
	atlas["Align"] = align_choose.text
	
	for variant in namesfonts.keys():
		atlas["Names"][variant] = namesfonts[variant][0]
		atlas["Fonts"][variant] = namesfonts[variant][1]
	
	for node in moods.get_children():
		atlas["Moods"][node.get_mood_name()] = node.get_mood_texture()
	
	return [name, atlas]
	
func change_name(new_name : String):
	person_name.text = new_name

func mood_texture_picked(path : String):
	var new_mood = pck_mood.instance()
	moods.add_child(new_mood)
	new_mood.my_person = name
	
	if new_mood.set_new_texture(path):
		new_mood.set_mood_name(path.rsplit("/", true, 1)[1].rsplit(".", true, 1)[0])
		Global.add_name_meta(moods.get_children(), "get_mood_name", true)
	else: new_mood.queue_free()

func _on_AddBt_pressed():
	var ext = []
	
	ext.append("*.png ; Portable Network Grafics")
	ext.append("*.bmp ; Bitmap Pictures")
	ext.append("*.jpg, *.jpeg ; Joint Photographic Experts Group Images")
	
	Global.open_file(funcref(self, "mood_texture_picked"), ext, "Pick picture")

func go_delete():
	lang_manager.queue_free()
	queue_free()

func _on_Delete_pressed():
	Global.confurm_something(funcref(self, "go_delete"), "Are you sure you want to delete this person (with all moods)?")

func _on_LangChangeBt_item_selected(index):
	while !is_instance_valid(lang_choose): yield(get_tree(), "idle_frame")
	lang_manager.change_current_lang(lang_choose.get_item_text(index))

func _on_FontChoose_item_selected(index):
	lang_manager.save_info()

func _on_DialogName_text_changed(new_text):
	lang_manager.save_info()

func _on_Grid_child_exiting_tree(node):
	var childs = moods.get_children()
	
	if node in childs:
		childs.erase(node)
	
	Global.add_name_meta(childs, "get_mood_name", true)

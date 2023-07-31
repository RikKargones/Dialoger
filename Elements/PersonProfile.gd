extends MarginContainer

class_name PersonProfile

onready var font_choose 	= $Moods/Settings/FontChoose
onready var lang_choose		= $Moods/Settings/LangChangeBt
onready var align_choose	= $Moods/Settings/Align
onready var person_name 	= $Moods/Settings/DialogName
onready var moods			= $Moods/Moods/Scroll/Grid

onready var pck_mood		= preload("res://Elements/Mood.tscn")

var person_id 		= ""
var current_lang 	= LangluageData.get_locales_list()[0]
	
func _ready():
	PersonsData.add_person(name)

func update_from_global():
	set_langluage(current_lang)

func mood_texture_picked(path : String):
	var new_mood = pck_mood.instance()
	moods.add_child(new_mood)
	new_mood.my_person = name
	
	if new_mood.set_new_texture(path):
		new_mood.set_mood_name(path.rsplit("/", true, 1)[1].rsplit(".", true, 1)[0])
		Global.add_name_meta(moods.get_children(), "get_mood_name", true)
	else: new_mood.queue_free()

func set_langluage(lang_name : String):
	if !LangluageData.is_locale_in_list(lang_name): return
	
	current_lang = lang_name
	
	font_choose.select_by_text(PersonsData.get_person_font_name(name, current_lang))
	
	align_choose.select(PersonsData.get_person_align(name))
	
	person_name.text = PersonsData.get_person_name(name, current_lang)

func on_delete():
	PersonsData.erase_person(name)
	queue_free()

func _on_AddBt_pressed():
	var ext = []
	
	ext.append("*.png ; Portable Network Grafics")
	ext.append("*.bmp ; Bitmap Pictures")
	ext.append("*.jpg, *.jpeg ; Joint Photographic Experts Group Images")
	
	Global.open_file(funcref(self, "mood_texture_picked"), ext, "Pick picture")

func _on_Delete_pressed():
	Global.confurm_something(funcref(self, "on_delete"), "Are you sure you want to delete this person (with all moods)?")

func _on_LangChangeBt_item_selected(index):
	set_langluage(lang_choose.get_item_text(index))

func _on_Align_item_selected(index):
	PersonsData.set_person_align(name, index)

func _on_FontChoose_item_selected(index):
	var fontname = font_choose.get_item_text(index)
	
	PersonsData.set_person_font_name(name, current_lang, fontname)
	
	font_choose.remove_font_override("font")
	
	if FontsData.is_font_in_list(fontname):
		font_choose.add_font_override("font", FontsData.get_font(fontname))
	elif FontsData.is_font_in_list(LangluageData.get_locale_font(current_lang)):
		font_choose.add_font_override("font", FontsData.get_font(LangluageData.get_locale_font(current_lang)))

func _on_DialogName_text_changed(new_text):
	PersonsData.set_person_name(name, current_lang, new_text)

func _on_Grid_child_exiting_tree(node):
	var childs = moods.get_children()
	
	if node in childs:
		childs.erase(node)
	
	Global.add_name_meta(childs, "get_mood_name", true)

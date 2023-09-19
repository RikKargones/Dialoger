extends MarginContainer

class_name Mood

var person_id		= ""
var data_name 		= ""

onready var name_node 	= $Margin/Lines/NameSuff/Name
onready var warn_node 	= $Margin/Lines/NameSuff/Suffix
onready var tex_node 	= $Margin/Lines/TextureRect

func get_mood_name():
	return data_name

func set_mood_name(new_name : String):
	name_node.text = new_name
	data_name = new_name
	_on_Name_text_changed(new_name)

func call_file_choose():
	var ext = []
	
	ext.append("*.png ; Portable Network Grafics")
	ext.append("*.bmp ; Bitmap Pictures")
	ext.append("*.jpg, *.jpeg ; Joint Photographic Experts Group Images")
	
	Global.open_file(funcref(self, "set_new_texture"), ext, "Выберете изображение")

func update_texture():
	if PersonsData.is_mood_in_person(person_id, data_name): tex_node.texture = PersonsData.get_person_mood_texture(person_id, data_name)
	else: queue_free()

func set_new_texture(path : String):
	if !PersonsData.is_person_in_list(person_id): return
	
	PersonsData.set_person_mood(person_id, data_name, path)

func _on_GetNewTexBt_pressed():
	call_file_choose()

func _on_DeleteBt_pressed():
	PersonsData.erase_person_mood(person_id, data_name)
	queue_free()

func _on_Name_text_changed(new_text : String):
	if new_text == "":
		name_node.text = data_name
		name_node.caret_position = data_name.length()
	elif !PersonsData.is_mood_in_person(person_id, new_text):
		PersonsData.change_person_mood_name(person_id, data_name, new_text)
		data_name = new_text
	
	warn_node.visible = data_name != name_node.text
	warn_node.hint_tooltip = "Some other mood has same name.\nThis mood will showed in editor and saved as \"" + data_name + "\"."
	

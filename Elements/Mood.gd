extends MarginContainer

var old_text 	= ""
var file		= ""
var my_person	= "None"

onready var name_node = $Margin/Lines/NameSuff/Name
onready var suff_node = $Margin/Lines/NameSuff/Suffix
onready var tex_node = $Margin/Lines/TextureRect

func get_mood_name():
	return name_node.text + suff_node.text
	
func get_mood_texture():
	return [tex_node.texture, file]

func _physics_process(delta):
	if Global.is_someone_has_my_name(self, name_node.text):
		var suff = 2
		var new_suff_name = " (Var. "+ str(suff) + ")"
		
		while Global.is_someone_has_my_name(self, name_node.text + new_suff_name):
			suff += 1
			new_suff_name =" (Var. "+ str(suff) + ")"
		
		suff_node.text = new_suff_name
	else:
		suff_node.text = ""

func set_mood_name(new_name : String):
	name_node.text = new_name.split(" Var.", true, 1)[0]

func set_new_texture(path : String):
	if file != "": FileManger.unregister_temp_file(file)
	
	var new_image 	= Image.new()
	var loaded_file	= FileManger.register_temp_file(path, "Res/"+my_person+"/Moods")
	
	if loaded_file.size() > 1:
		file = loaded_file[0]
		if new_image.load(loaded_file[1] + "/" + file) == OK:
			var new_texture = ImageTexture.new()
			new_texture.create_from_image(new_image)
			tex_node.texture = new_texture
			return true
	
	return false

func call_file_choose():
	var ext = []
	
	ext.append("*.png ; Portable Network Grafics")
	ext.append("*.bmp ; Bitmap Pictures")
	ext.append("*.jpg, *.jpeg ; Joint Photographic Experts Group Images")
	
	Global.open_file(funcref(self, "set_new_texture"), ext, "Выберете изображение")

func _on_GetNewTexBt_pressed():
	call_file_choose()

func _on_DeleteBt_pressed():
	FileManger.unregister_temp_file(file)
	queue_free()

func _on_Name_text_changed(new_text):
	if new_text == "":
		name_node.text = old_text
		name_node.caret_position = old_text.length()
	else: old_text = new_text

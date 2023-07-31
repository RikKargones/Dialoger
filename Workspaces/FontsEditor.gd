extends MarginContainer

var replace_load_mode 		= false
var replace_font_child_id 	= null
var replace_font_name		= ""

var temp_main_font_file		= ""

onready var font_list = $Full/List

onready var pck_font = preload("res://Elements/FontSettings.tscn")

func _ready():
	FontsData.connect("refresh_data", self, "set_fonts")

func make_new_font(path : String):
	FontsData.add_font(path)

func set_fonts():
	var fonts 		= FontsData.get_fonts_list()
	var font_def 	= FontsData.get_font_defalut()
	
	fonts.erase(FontsData.get_font_name_defalut())
	
	for child in font_list.get_children():
		if child is FontElement:
			var font_name = child.get_font_name()
			
			if font_name in fonts:
				child.set_font(font_name, FontsData.get_font(font_name), font_def == font_name)
				fonts.erase(font_name)
			else:
				child.queue_free()
	
	for font_name in fonts:
		var new_font = pck_font.instance()
		
		font_list.add_child(new_font)
		new_font.set_font(font_name, FontsData.get_font(font_name), font_def == font_name)

func show_file_dialog():
	Global.open_file(funcref(self, "make_new_font"), ["*.otf ; Open Type Font", "*.ttf ; True Type Font"], "Выберете файл шрифта")

func _on_AddBt_pressed():
	show_file_dialog()

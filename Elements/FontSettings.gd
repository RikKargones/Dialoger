extends MarginContainer

class_name FontElement

onready var size 			= $Scroll/All/Font/Settings/Size/FontSize

onready var outline_on 		= $Scroll/All/Font/Settings/Outline/Outline
onready var outline_size 	= $Scroll/All/Font/Settings/Outline/OutlineSize
onready var outline_color	= $Scroll/All/Font/Settings/Outline/OutlineColor

onready var spacing_top		= $Scroll/All/Font/Settings/Spacing/Top
onready var spacing_bottom	= $Scroll/All/Font/Settings/Spacing/Bottom
onready var spacing_char	= $Scroll/All/Font/Settings/Spacing/Char
onready var spacing_space	= $Scroll/All/Font/Settings/Spacing/Space

onready var paronims 		= $Scroll/All/Font/Tests/TestTexts
onready var test_filed		= $Scroll/All/Font/Tests/TestFiled

var font_name 	= ""
var font 		= DynamicFont.new()
var is_defalut	= false

signal deleted

func get_font_name():
	return font_name

func set_font(f_name : String, new_font : DynamicFont, defalut : bool):
	paronims.remove_font_override("font")
	test_filed.remove_font_override("font")
	
	paronims.add_font_override("font", new_font)
	test_filed.add_font_override("font", new_font)
	
	font_name 	= f_name
	name 		= font_name
	font 		= new_font
	is_defalut	= defalut

func set_font_defalut():
	FontsData.set_user_defalut_font(font_name)
	is_defalut = true

func set_settings_from_font():
	size.value 				= font.size
	
	outline_on.pressed 		= (font.outline_size != 0)
	outline_size.value 		= font.outline_size
	outline_color.color		= font.outline_color
	
	spacing_top.value		= font.extra_spacing_top
	spacing_bottom.value	= font.extra_spacing_bottom
	spacing_char.value		= font.extra_spacing_char
	spacing_space			= font.extra_spacing_space

func on_font_file_open(path : String):
	FontsData.change_font_data(font_name, path)

func on_font_file_rename(new_name : String):
	FontsData.change_font_name(font_name, new_name)

func on_delete():
	emit_signal("deleted", self)
	queue_free()

func _on_RenameBt_pressed():
	Global.name_something(funcref(self, "on_font_file_rename"), "Make new font name", FontsData.get_fonts_list(), true)

func _on_ReloadBt_pressed():
	Global.open_file(funcref(self, "on_font_file_open"), ["*.otf ; Open Type Font", "*.ttf ; True Type Font"], "Choose new font file")

func _on_DeleteBt_pressed():
	Global.confurm_something(funcref(self, "on_delete"), "Вы уверены, что хотите удалить этот шрифт?\nЭтот шрифт будет заменен на дефолтный в проекте.")

func _on_FontSize_value_changed(value : int):
	font.size = value

func _on_Outline_toggled(button_pressed : bool):
	if button_pressed:
		font.outline_size 	= outline_size.value
		font.outline_color 	= outline_color.color
	else:
		font.outline_size 	= 0
		font.outline_color 	= Color.white

func _on_OutlineSize_value_changed(value : int):
	if outline_on.pressed: font.outline_size = value

func _on_OutlineColor_color_changed(color : Color):
	if outline_on.pressed: font.outline_color = color

func _on_Top_value_changed(value : int):
	font.extra_spacing_top = value

func _on_Bottom_value_changed(value : int):
	font.extra_spacing_bottom = value

func _on_Char_value_changed(value : int):
	font.extra_spacing_char = value

func _on_Space_value_changed(value : int):
	font.extra_spacing_space = value

func _on_Minimaps_toggled(button_pressed : int):
	font.use_mipmaps = button_pressed

func _on_Filter_toggled(button_pressed : int):
	font.use_filter = button_pressed

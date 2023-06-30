extends MarginContainer

var main_font = DynamicFont.new()
var font_file_name = ""

signal change_name (id, new_name)
signal change_font_data (id)

func get_main_font():
	return [main_font, font_file_name]

func set_main_font(font : DynamicFont, font_filename : String):
	main_font = font
	font_file_name = font_filename
	$Scroll/Settings/TestTexts.set("custom_fonts/font", font)
	$Scroll/Settings/TestFiled.set("custom_fonts/font", font)
	$Scroll/Settings/Size/SpinBox.value = Defaluts.default_font_size
	
func _physics_process(delta):
	main_font.size = $Scroll/Settings/Size/SpinBox.value

func rename(new_name : String):
	name = new_name

func _on_RenameBt_pressed():
	emit_signal("change_name", self)

func _on_ReloadBt_pressed():
	emit_signal("change_font_data", self, font_file_name)

func _on_DeleteBt_pressed():
	Global.confurm_something(funcref(self, "queue_free"), "Вы уверены, что хотите удалить этот шрифт?")

func _on_FontSettings_tree_exiting():
	FileManger.unregister_temp_file(font_file_name)

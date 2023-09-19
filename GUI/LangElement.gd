extends PanelContainer

class_name LocaleElement

onready var locale_full				= $Element/LangName
onready var locale_font_chooser 	= $Element/FontChoose
onready var locale_short			= $Element/LocaleShort

signal local_toggled(to)
signal font_changed(new_font)

func set_selection(on : bool):
	locale_full.pressed = on

func is_selected() -> bool:
	return locale_full.pressed

func get_locale_full() -> String:
	return locale_full.text
	
func get_locale_short() -> String:
	return locale_short.text
	
func get_locale_font() -> String:
	return locale_font_chooser.text
	
func set_locale_name(new_name : String):
	locale_full.text = new_name
	
func set_locale_short(new_name : String):
	locale_short.text = new_name

func set_locale_font(font_name : String):
	if font_name in ProjectManager.get_all_fonts().keys():
		for item in locale_font_chooser.get_item_count():
			if locale_font_chooser.get_item_text(item) == font_name:
				locale_font_chooser.select(item)

func _on_LangName_toggled(button_pressed):
	emit_signal("local_toggled", button_pressed)

func _on_FontChoose_item_selected(index):
	emit_signal("font_changed", locale_font_chooser.get_item_text(index))

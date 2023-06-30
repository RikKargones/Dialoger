extends HBoxContainer

onready var mode_button 	= $TransMode
onready var lang_changer 	= $LangChoose
onready var label			= $Label

signal mode_changed
signal lang_seted

func _ready():
	call_traslation_update()

func call_traslation_update():
	_on_TransMode_toggled(mode_button.pressed)

func get_mode() -> bool:
	return mode_button.pressed
	
func get_lang() -> String:
	if lang_changer.selected != -1:
		return lang_changer.get_item_text(lang_changer.selected)
	return ""

func update_lang_list(by : Array):
	Global.update_selector(lang_changer, by)
	emit_signal("lang_seted", get_lang())

func _on_TransMode_toggled(button_pressed):
	label.visible 			= button_pressed
	lang_changer.visible 	= button_pressed
	emit_signal("mode_changed", get_mode(), get_lang())

func _on_LangChoose_item_selected(_index):
	emit_signal("lang_seted", get_lang())

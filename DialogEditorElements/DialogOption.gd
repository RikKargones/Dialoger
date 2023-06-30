extends HBoxContainer

class_name DialogOption

signal option_edit_opend(self_id)
signal option_edit_closed(self_id)

onready var opt_name = $OptionName
onready var state_bt = $StatementBt

func hide_logic_edit():
	state_bt.pressed = false
	state_bt._pressed()

func get_opt_name_filed_position():
	return opt_name.rect_position + rect_position

func set_option_font(font : Font):
	opt_name.set_deferred("custom_fonts/font", font)

func set_option_name(new_name : String):
	opt_name.text = new_name

func get_option_name():
	return opt_name.text

func get_logic_info():
	return state_bt.get_logic_scheme()
	
func set_logic_info(data : Array):
	state_bt.set_logick_scheme(data)

func _on_DeleteBt_pressed():
	queue_free()

func _on_StatementBt_toggled(button_pressed):
	if button_pressed: emit_signal("option_edit_opend", self)
	else: emit_signal("option_edit_closed", self)

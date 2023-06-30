extends MarginContainer

onready var var_name		= $All/Label
onready var type_changer 	= $All/Start/TabContainer
onready var bool_set		= $All/Start/TabContainer/CheckButton
onready var int_set			= $All/Start/TabContainer/SpinBox
onready var string_set		= $All/Start/TabContainer/LineEdit
onready var current_vis		= $All/Current
onready var current_shower 	= $All/Current/CurrentValue

signal var_changed(var_name, value)

func _ready():
	current_vis.visible = false

func set_current_vis(vis : bool):
	current_vis.visible = vis

func set_varible(which : String, value):
	var_name.text = which
	
	match typeof(value):
		TYPE_BOOL:
			type_changer.current_tab = 1
			bool_set.pressed = value
		TYPE_INT:
			type_changer.current_tab = 2
			int_set.value = value
		TYPE_STRING:
			type_changer.current_tab = 3
			string_set.text = value
		_:
			type_changer.current_tab = 0
		
func get_varible_name():
	return var_name.text

func get_varible_value():
	match type_changer.current_tab:
		_:
			return null
		1:
			return bool_set.pressed
		2:
			return int_set.value
		3:
			return string_set.text

func _on_CheckButton_toggled(button_pressed):
	emit_signal("var_changed", var_name.text, button_pressed)

func _on_SpinBox_value_changed(value):
	emit_signal("var_changed", var_name.text, value)
	
func _on_LineEdit_text_changed(new_text):
	emit_signal("var_changed", var_name.text, new_text)

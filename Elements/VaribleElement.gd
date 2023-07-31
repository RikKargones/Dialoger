extends MarginContainer

class_name VaribleElement

onready var namer 			= $Settings/VarName
onready var warner 			= $Settings/Warning
onready var type_choser 	= $Settings/OptionButton
onready var type_fileds 	= $Settings/TypeFileds

onready var bool_filed		= $Settings/TypeFileds/Bool/CheckButton
onready var string_filed 	= $Settings/TypeFileds/String/StringFiled
onready var int_filed		= $Settings/TypeFileds/Int/IntFiled

signal delited(me)
signal changed_type(me, value)

func set_name(new_name : String):
	namer.text = new_name

func get_name() -> String:
	return namer.text

func set_value(value):
	match typeof(value):
		TYPE_BOOL:
			bool_filed.pressed = value
			set_from_index(0)
		TYPE_STRING:
			string_filed.text = value
			set_from_index(1)
		TYPE_INT:
			int_filed.value = value
			set_from_index(2)
		_:
			set_from_index(3)

func get_current_value():
	return get_value(type_choser.selected)

func get_value(filed : int):
	match filed:
		0:
			return bool_filed.pressed
		1:
			return string_filed.text
		2:
			return int_filed.value
		_:
			return null

func set_from_index(index : int):
	match index:
		0, 1, 2:
			type_fileds.current_tab = index
			emit_signal("changed_type", get_name(), get_value(index))
		_:
			type_fileds.current_tab = 3
			emit_signal("changed_type", get_name(), null)

func _on_OptionButton_item_selected(index):
	set_from_index(index)

func _on_DeleteBt_pressed():
	Global.confurm_something(funcref(self, "on_delete"), "Вы точно хотите удалить переменную?")

func on_delete():
	emit_signal("delited", get_name())
	queue_free()

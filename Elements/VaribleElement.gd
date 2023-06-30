extends MarginContainer

onready var namer 			= $Settings/VarName
onready var warner 			= $Settings/Warning
onready var type_choser 	= $Settings/OptionButton
onready var type_fileds 	= $Settings/TypeFileds

onready var bool_filed		= $Settings/TypeFileds/Bool/CheckButton
onready var string_filed 	= $Settings/TypeFileds/String/StringFiled
onready var int_filed		= $Settings/TypeFileds/Int/IntFiled

func _physics_process(delta):
	 warner.visible = Global.is_someone_has_my_name(self, get_name()) || get_name() == ""

func set_name(new_name : String):
	namer.set_deferred("text", new_name)

func get_name() -> String:
	return namer.text

func set_info(arr : Array):	
	for type in type_choser.get_item_count():
		if type_choser.get_item_text(type) == arr[0]:
			type_choser.select(type)
	
	match type_choser.selected:
		0:
			bool_filed.pressed = arr[1]
		1:
			string_filed.text = arr[1]
		2:
			int_filed.value = arr[1]

func get_info():
	return [get_name(), type_choser.text, get_start_value()]
	
func is_in_warning():
	return warner.visible
	
func get_start_value():
	match type_choser.selected:
		0:
			return bool_filed.pressed
		1:
			return string_filed.text
		2:
			return int_filed.value
		_:
			return null

func _on_OptionButton_item_selected(index):
	type_fileds.current_tab = index

func _on_DeleteBt_pressed():
	Global.confurm_something(funcref(self, "queue_free"), "Вы точно хотите удалить переменную?")

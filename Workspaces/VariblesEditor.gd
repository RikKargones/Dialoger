extends MarginContainer

onready var list = $Editor/Scroll/List

onready var pck_varible = preload("res://Elements/VaribleElement.tscn")

func _ready():
	VariblesData.connect("refresh_data", self, "on_data_refresh")

func make_new_varible(new_name : String):
	var new_var = pck_varible.instance()
	list.add_child(new_var)
	new_var.set_name(new_name)
	new_var.connect("delited", VariblesData, "delete_varible")
	new_var.connect("changed_type", VariblesData, "set_varible")
	return new_var

func update_element_silent(elem : VaribleElement):
	elem.disconnect("changed_type", VariblesData, "set_varible")
	elem.set_value(VariblesData.get_initial_value(elem.get_name()))
	elem.connect("changed_type", VariblesData, "set_varible")

func on_data_refresh():
	var var_list = VariblesData.get_varibles_list()
	
	for elem_var in list.get_children():
		if elem_var is VaribleElement:
			var var_name = elem_var.get_name()
			
			if var_name in var_list:
				update_element_silent(elem_var)
				var_list.erase(var_name)
			else:
				elem_var.disconnect("delited", VariblesData, "delete_varible")
				elem_var.queue_free()
	
	for varible in var_list:
		update_element_silent(make_new_varible(varible))

func _on_Add_Bt_pressed():	
	Global.name_something(funcref(self, "make_new_varible"), "Укажите уникальное название переменной!", VariblesData.get_varibles_list(), true)

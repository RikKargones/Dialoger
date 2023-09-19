extends MarginContainer

onready var list			= $Full/List
onready var pck_profile 	= preload("res://Elements/PersonProfile.tscn")

func _ready():
	set_from_data()
	PersonsData.connect("refresh_data", self, "set_from_data")
	
func set_from_data():
	var persons_list = PersonsData.get_persons_list()
	
	for child in list.get_children():
		if child is PersonProfile:
			if child.name in persons_list:
				child.update_from_global()
				persons_list.erase(child.name)
			else:
				child.queue_free()
	
	for person in persons_list:
		make_new(person, false)

func make_new(new_name : String, add = true):
	var person_inst 	= pck_profile.instance()
	
	person_inst.name 	= new_name
	
	if add:
		PersonsData.add_person(new_name)
		person_inst.update_from_global()
	else:
		person_inst.update_from_global()
	
	list.add_child(person_inst)
	
	return person_inst

func _on_AddBt_pressed():
	Global.name_something(funcref(self, "make_new"), "Укажите внутреннее имя.", PersonsData.get_persons_list(), true)

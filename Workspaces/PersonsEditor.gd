extends MarginContainer

onready var list			= $Full/List
onready var pck_profile 	= preload("res://Elements/PersonProfile.tscn")

func _ready():
	ProjectManager.set_persons_collector(funcref(self, "update_gloabal_atlas"))
	ProjectManager.connect("clear_project", self, "clear_data")
	SaveManager.pers_update_funcref = funcref(self, "set_all_persons")

func clear_data():
	for node in list.get_children():
		node.queue_free()

func set_all_persons():
	var atlas = ProjectManager.persons_atlas.duplicate(true)
	
	for person in atlas.keys():
		on_confirmation_new(person)
		list.get_children()[list.get_child_count() - 1].set_person_info([person, atlas[person]])
	
	update_gloabal_atlas()
	
func get_all_personas() -> Dictionary:
	var persons_atlas = {}
	
	for node in list.get_children():
		var info = node.get_person_info()
		persons_atlas[info[0]] = info[1]
	
	return persons_atlas

func update_gloabal_atlas():
	ProjectManager.update_persons_atlas(get_all_personas())

func _on_AddBt_pressed():
	var names = []
	
	for node in list.get_children():
		names.append(node.name)
	
	Global.name_something(funcref(self, "on_confirmation_new"), "Укажите внутреннее имя.", names, true)

func on_confirmation_new(new_name : String):
	var person_inst 	= pck_profile.instance()
	person_inst.name 	= new_name
	
	list.add_child(person_inst)
	person_inst.change_name(new_name)

func _on_PersonsProfiles_visibility_changed():
	update_gloabal_atlas()

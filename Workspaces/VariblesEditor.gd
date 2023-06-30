extends MarginContainer

onready var list = $Editor/Scroll/List

onready var pck_varible = preload("res://Elements/VaribleElement.tscn")

func _ready():
	ProjectManager.set_varibles_collector(funcref(self, "update_global_atlas"))
	ProjectManager.connect("clear_project", self, "clear_data")
	SaveManager.var_update_funcref = funcref(self, "set_varibles")

func clear_data():
	for node in list.get_children():
		node.queue_free()

func _physics_process(delta):
	Global.add_name_meta(list.get_children(), "get_name", true)

func _on_Add_Bt_pressed():
	var names = []
	
	for child in list.get_children():
		names.append(child.get_name())
	
	Global.name_something(funcref(self, "make_new_varible"), "Укажите уникальное название переменной!", names, true)

func set_varibles():
	for varible in ProjectManager.varibles_atlas.keys():
		make_new_varible(varible)
		list.get_children()[list.get_child_count()-1].set_info(ProjectManager.varibles_atlas[varible])
	
func make_new_varible(new_name : String):
	var new_varible = pck_varible.instance()
	list.add_child(new_varible)
	new_varible.set_name(new_name)

func update_global_atlas():
	var data = {}
	
	for child in list.get_children():
		if !child.is_in_warning():
			var child_data = child.get_info()
			data[child_data[0]] = [child_data[1], child_data[2]]
		
	ProjectManager.update_varibles_atlas(data)

func _on_VariblesEditor_visibility_changed():
	update_global_atlas()

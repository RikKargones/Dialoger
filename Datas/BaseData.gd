extends Node

class_name BaseData

signal refresh_data

var data = {}

func _init():
	set_key_by_defalut()

func _ready():
	ProjectManager.connect("clear_project", self, "set_key_by_defalut")
	ready_prepare()

func ready_prepare():
	pass

func set_key_by_defalut():
	data.clear()
	emit_signal("refresh_data")

func get_data() -> Dictionary:
	return data

func set_data(new_data : Dictionary):
	if new_data.hash() != data.hash():
		ProjectManager.project_unsaved = true
		data = new_data

func _set_data_from_save(save_data : Dictionary):
	data = save_data
	emit_signal("refresh_data")

func _get_save_data() -> Dictionary:
	return data
	
func _get_export_data() -> Dictionary:
	return _get_save_data()

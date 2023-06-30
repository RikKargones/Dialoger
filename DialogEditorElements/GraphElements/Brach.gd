extends DialogBase

var pck_logick_button = preload("res://DialogEditorElements/DialogOption.tscn")

func _ready():
	parent_class_instansing()
	dialog_type = Global.DialogType.Branch

func _on_AddBt_pressed():
	add_option()

func add_option():
	var new_element = pck_logick_button.instance()
	
	add_child(new_element)
	set_slot_enabled_right(get_child_count() - 1, true)
	
	return new_element

func _on_Brach_child_exiting_tree(node):
	remove_slot(node)

func get_custom_replic_settings() -> Dictionary:
	var info = []
	
	for node in get_children():
		if !node.is_in_group("NOCHECK"):
			info.append( {"Name" : node.get_option_name(), "Logic" : node.get_logic_info()} )
			
	return {"Options" : info}

func set_custom_settings_from_dict(data : Dictionary):
	for key in data.keys():
		match key:
			"Options":
				for item in data["Options"]:
					var option = add_option()
					option.set_option_name(item["Name"])
					option.set_logic_info(item["Logic"])

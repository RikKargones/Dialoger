extends GraphNode

class_name BasicGraphNode

export var type_id 				= 0
export var can_be_as_start_node = false

var is_menu_blocked	= false

func _get_custom_actions() -> Dictionary:
	return {}

func set_as_start():
	if can_be_as_start_node:
		DialogData.add_start_node(ProjectManager.get_edit_dialog(), name)
	
func remove_as_start():
	DialogData.erase_start_node(ProjectManager.get_edit_dialog(), name)

func block_menu():
	is_menu_blocked = true
	
func unblock_menu():
	is_menu_blocked = false

func register_as_block(block : BasicGraphBlock, count_same : int):
	var base_index 	= block.get_base_dialog_index()
	var full_key	= str(base_index) + "_" + str(count_same)
	
	if base_index == Defaluts.DIALOG_BLOCKS.NONE: return
	
	if !DialogData.is_key_in_node(ProjectManager.get_edit_dialog(), name, full_key):
		DialogData.add_key_in_node(ProjectManager.get_edit_dialog(), name, full_key, block._gather_block_info())
	
	block.bound_to_node(name)
	block.bound_to_key(full_key)
	
func rename_node(new_name : String):
	DialogData.rename_node_in_dialog(ProjectManager.get_edit_dialog(), name, new_name)
	name = new_name	

func get_node_type() -> int:
	return type_id

func gather_actions() -> Dictionary:
	var actions = {}
	
	if can_be_as_start_node:
		if DialogData.is_node_in_start(ProjectManager.get_edit_dialog(), name): actions["Remove as start"] = funcref(self, "remove_as_start")
		else: actions["Set as start"] = funcref(self, "set_as_start")
	
	actions.merge(_get_custom_actions(), true)
	
	return actions

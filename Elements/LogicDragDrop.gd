extends Button

class_name DragDropLogic

var my_root		= null

signal replaced(data)

func get_my_root():
	return my_root

func initialase_root(node : Control):
	my_root = node

func update_by_data(data : Array):
	pass

func duplicate_me():
	return self.duplicate()
	
func get_drag_data(position):
	var new_logic 			= duplicate_me()
	var send_me				= duplicate_me()
	var centr_control		= MarginContainer.new()
	
	send_me.size_flags_horizontal	= 0
	new_logic.size_flags_horizontal	= 0
	
	new_logic.rect_position = -new_logic.rect_size / 2
	
	centr_control.add_child(new_logic)
	
	set_drag_preview(centr_control)
	
	return [send_me, self]
	
func can_drop_data(position, data):
	return is_instance_valid(my_root) && my_root.child_check_drop(position, data, self)

func drop_data(position, data):
	if is_instance_valid(my_root):
		my_root.child_drop_data(position, data, self)

func get_my_info() -> Array:
	return ["NULL"]

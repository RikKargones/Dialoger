extends MarginContainer

class_name StatementLine

onready var filed 			= $Block/Statements
onready var position_shower = $Shower/Order
onready var shower_rect		= $Shower/Order/ColorRect

var warning_text = ""

signal warned(warn_text)

func _physics_process(delta):
	if Input.is_action_just_released("mouse_left_button"):
		position_shower.visible = false
	
	check_correction()

func determ_on_wich_child(position):	
	for child in filed.get_children():
		var pos 	= child.rect_position + filed.rect_position
		var size 	= child.rect_size
		
		if pos.x <= position.x && pos.x + size.x >= position.x && pos.y <= position.y && pos.y + size.y >= position.y:
			return child.get_position_in_parent()
			
	return filed.get_child_count()

func add_child_to_filed(node : DragDropLogic):
	filed.add_child(node)

func child_drop_data(position, data, child):
	position += filed.rect_position + child.rect_position
	drop_data(position, data)

func drop_data(position, data):
	if is_instance_valid(data[1].get_my_root()) && data[1].get_my_root() == self:
		filed.move_child(data[1], determ_on_wich_child(position))
	elif is_instance_valid(data[1].get_my_root()):
		filed.add_child(data[0])
		filed.move_child(data[0], determ_on_wich_child(position))
		data[0].initialase_root(self)
		data[1].queue_free()
	else:
		filed.add_child(data[0])
		filed.move_child(data[0], determ_on_wich_child(position))
		data[0].initialase_root(self)

func check_correction():
	var statement_str 	= "get_expression_result( "
	var express			= Expression.new()
	var all_vars		= ProjectManager.get_all_varibles()
	
	for cld in filed.get_children():
		
		var info = cld.get_my_info()
		match info[0]:
			"VAR":
				var set = info[1]
				
				if set in all_vars.keys():
					set = all_vars[set][1]
					if set is String:
						set = "\"" + set + "\""
				
				statement_str += str(set) + " " + str(info[2]) + " " + str(info[3]) + " " 
			"NOT":
				statement_str += "! "
			"AND":
				statement_str += "&& "
			"OR":
				statement_str += "|| "
			"BRSO":
				statement_str += "( "
			"BRSC":
				statement_str += ") "
	
	statement_str += ")"
	
	statement_str = statement_str.replace("False", "false")
	statement_str = statement_str.replace("True", "true")
	
	var erorr = express.parse(statement_str)
	
	if erorr != OK && statement_str != "":
		if express.get_error_text() != warning_text:
			warning_text = express.get_error_text() 
			emit_signal("warned", warning_text)
	elif warning_text != "":
		warning_text = ""
		emit_signal("warned", warning_text)

func get_expression_result(formula : bool):
	return formula

func child_check_drop(position, data, who : Control):
	var check_pos = filed.rect_position
	check_pos += who.rect_position
	check_pos += position
	return can_drop_data(check_pos, data)

func can_drop_data(position, data):
	var zone_start		= filed.rect_position.x
	var zone_finish 	= filed.rect_position.x + filed.rect_size.x 
	var in_zone 		= zone_start < position.x && zone_finish > position.x
	
	if in_zone:
		if filed.get_child_count() > 0:
			for child in filed.get_children():
				var pos 	= filed.rect_position + child.rect_position
				var size 	= child.rect_size
				
				if pos.x <= position.x && pos.x + size.x >= position.x && pos.y <= position.y && pos.y + size.y >= position.y:
					position_shower.rect_position 	= pos
					shower_rect.rect_min_size.y 	= child.rect_size.y
					position_shower.rect_size.y 	= 0
					position_shower.visible			= true
					
					return true
			
			var last_child = filed.get_child(filed.get_child_count() - 1)
			
			position_shower.rect_position	= filed.rect_position + last_child.rect_position
			position_shower.rect_position.x	+= last_child.rect_size.x
			shower_rect.rect_min_size.y 	= last_child.rect_size.y
			position_shower.rect_size.y 	= 0
			position_shower.visible			= true
			
			return true
		else:
			position_shower.rect_position 	= filed.rect_position
			shower_rect.rect_min_size.y 	= data[0].rect_size.y
			position_shower.rect_size.y 	= 0
			position_shower.visible 		= true
			
			return true
	
	position_shower.visible = false
	
	return false

func gather_all_logic():
	var info = []
	
	for node in filed.get_children():
		info.append(node.get_my_info())
	
	return info
	
func _on_IfStatement_mouse_exited():
	position_shower.visible = false

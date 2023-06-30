extends Button

onready var state_edit 			= $StatementEditor
onready var warning_label		= $StatementEditor/Container/Margin2/Blocks/DragDrops/ErrorString/WarnLabel
onready var if_statement		= $StatementEditor/Container/Margin/Scroll/IfStatement

onready var st_not				= $StatementEditor/Container/Margin2/Blocks/DragDrops/Line1/Not
onready var st_and				= $StatementEditor/Container/Margin2/Blocks/DragDrops/Line1/And
onready var st_or				= $StatementEditor/Container/Margin2/Blocks/DragDrops/Line1/Or
onready var st_brs_o			= $StatementEditor/Container/Margin2/Blocks/DragDrops/Line1/BrascetsO
onready var st_brs_c			= $StatementEditor/Container/Margin2/Blocks/DragDrops/Line1/BrascetsC
onready var st_varible			= $StatementEditor/Container/Margin2/Blocks/DragDrops/LogicVarible

func _ready():
	_pressed()

func _pressed():
	if is_instance_valid(get_parent()) && get_parent() is Control:
		var diff = get_parent().rect_size.x - rect_position.x
		state_edit.rect_position = Vector2(diff + 20, 0)
	else:	
		state_edit.rect_position = Vector2(rect_size.x + 20, 0)
		
	state_edit.visible = pressed

func get_logic_scheme():
	return if_statement.gather_all_logic()
	
func set_logick_scheme(data : Array):
	for info in data:
		match info[0]:
			"NOT":
				var new = st_not.duplicate_me()
				new.size_flags_horizontal = 0
				if_statement.add_child_to_filed(new)
			"AND":
				var new = st_and.duplicate_me()
				new.size_flags_horizontal = 0
				if_statement.add_child_to_filed(new)
			"OR":
				var new = st_or.duplicate_me()
				new.size_flags_horizontal = 0
				if_statement.add_child_to_filed(new)
			"BRSO":
				var new = st_brs_o.duplicate_me()
				new.size_flags_horizontal = 0
				if_statement.add_child_to_filed(new)
			"BRSC":
				var new = st_brs_c.duplicate_me()
				new.size_flags_horizontal = 0
				if_statement.add_child_to_filed(new)
			"VAR":
				var new = st_varible.duplicate_me()
				new.size_flags_horizontal = 0
				if_statement.add_child_to_filed(new)
				new.update_by_data(info)

func _on_IfStatement_warned(warn_text):
	warning_label.text = warn_text

func _on_Container_item_rect_changed():
	$StatementEditor.rect_size = Vector2()

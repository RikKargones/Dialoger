extends DragDropLogic

onready var state_choose 	= $MarginContainer/Settings/StatementSelector
onready var var_selector 	= $MarginContainer/Settings/VaribleSelector
onready var settings_tabs 	= $MarginContainer/Settings/TabContainer
onready var int_settings	= $MarginContainer/Settings/TabContainer/Int
onready var str_settings	= $MarginContainer/Settings/TabContainer/String
onready var bool_settings	= $MarginContainer/Settings/TabContainer/Bool

func _ready():
	update_selectors()

func _physics_process(delta):
	rect_size.x = 0
	rect_min_size = $MarginContainer.rect_size

func update_selectors():
	var all_vars = ProjectManager.get_all_varibles()
	
	if var_selector.text in all_vars.keys():
		match all_vars[var_selector.text][0]:
			"Bool":
				settings_tabs.visible = true
				settings_tabs.current_tab = 3
				Global.update_selector(state_choose, ["==", "!="])
				state_choose.visible = true
			"String":
				settings_tabs.visible = true
				settings_tabs.current_tab = 2
				Global.update_selector(state_choose, ["==", "!="])
				state_choose.visible = true
			"Integer":
				settings_tabs.visible = true
				settings_tabs.current_tab = 1
				Global.update_selector(state_choose, ["==", "!=", ">", "<", ">=", "<="])
				state_choose.visible = true
			_:
				settings_tabs.visible = false
				state_choose.visible = false
	else:
		settings_tabs.visible = false
		state_choose.visible = false

func _on_VaribleSelector_item_selected(index):
	update_selectors()

func update_by_data(data : Array):
	var all_vars = ProjectManager.get_all_varibles()
	
	if data.size() == 4:
		if data[1] in all_vars.keys():
			for item in var_selector.get_item_count():
				if var_selector.get_item_text(item) == data[1]:
					var_selector.select(item)
					update_selectors()
					break
		
			for item in state_choose.get_item_count():
				if state_choose.get_item_text(item) == data[2]:
					state_choose.select(item)
					break
					
			match all_vars[data[1]][0]:
				"Bool":
					bool_settings.pressed = data[3]
				"String":
					str_settings.text = data[3].split("\"", true, 1)[1].rsplit("\"", true, 1)[0]
				"Integer":
					int_settings.value = data[3]
		

func get_my_info() -> Array:
	var info 		= []
	var all_vars 	= ProjectManager.get_all_varibles()
	
	info.append("VAR")
	info.append(var_selector.text)
	info.append(state_choose.text)
	
	if var_selector.text in all_vars.keys():
		match all_vars[var_selector.text][0]:
			"Bool":
				info.append(bool_settings.pressed)
			"String":
				info.append("\""+str(str_settings.text)+"\"")
			"Integer":
				info.append(int_settings.value)
			_:
				info.append(null)
	else:
		info.append(null)
	
	return info

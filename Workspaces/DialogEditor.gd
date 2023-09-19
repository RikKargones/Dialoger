extends MarginContainer

onready var map				= $Full/EditZone/Map

onready var locale_picker 	= $Full/Settings/LocalePicker
onready var dialog_picker	= $Full/Settings/DialogeChangeBt

onready var map_menu		= $Full/EditZone/MapMenu
onready var add_node_menu 	= $Full/EditZone/MapMenu/AddMenu

var hovered_node : BasicGraphNode

var node_types_list 	= {}
var selection			= []

var mouse_prev_position = Vector2()
var mouse_differince	= Vector2()
	
func _ready():
	update_add_nodes_menu()
	ProjectManager.connect("dialog_changed", self, "load_dialog")
	
func _physics_process(_delta):
	if visible:
		if Input.is_action_just_pressed("mouse_right_button") || Input.is_action_just_pressed("mouse_left_button"):
			if !Rect2(Vector2(), map_menu.rect_size).has_point(map_menu.get_local_mouse_position()):
				map_menu.hide()
		
		if Input.is_action_just_released("mouse_right_button"):
			if Rect2(Vector2(-10,-10),Vector2(20, 20)).has_point(mouse_differince): show_map_menu()
			else: mouse_differince = Vector2()
				
		if Input.is_action_pressed("mouse_right_button"):
			var diff = mouse_prev_position - map.get_local_mouse_position()
			map.scroll_offset += diff
			mouse_differince += diff
			
		mouse_prev_position = map.get_local_mouse_position()

func show_map_menu():
	if is_instance_valid(hovered_node):
		if hovered_node.is_menu_blocked: return
		
		var actions = hovered_node.gather_actions()
		
		map_menu.clear()
		
		for action in actions.keys():
			map_menu.add_item(action)
			map_menu.set_item_metadata(map_menu.get_item_count() - 1, actions[action])
			
	map_menu.add_submenu_item("Add node", "AddMenu")
	map_menu.rect_global_position = map.get_global_mouse_position()
	map_menu.popup()

func update_add_nodes_menu():
	var dir_manager = Directory.new()
	var path_to_nodes_dir = "res://DialogEditorElements/GraphElements"
	
	add_node_menu.clear()
	
	if dir_manager.open(path_to_nodes_dir) == OK:
		dir_manager.list_dir_begin(true, true)
		var file_name = dir_manager.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var pck : PackedScene = load(path_to_nodes_dir + "/" + file_name)
				var instance = pck.instance()
				
				if instance is BasicGraphNode:
					add_node_menu.add_item(file_name.trim_suffix(".tscn"), instance.get_node_type())
					node_types_list[instance.get_node_type()] = pck
					
			file_name = dir_manager.get_next()
		
		if node_types_list.size() == 0:
			Global.popup_error("DialogEditor: none of BasicGraphNodes packed scenes found.")
	else:
		Global.popup_error("DialogEditor: can't open path to BasicGraphNodes folder.")

func load_dialog(dialog_name : String):
	if !DialogData.is_dialog_in_list(dialog_name): return
	
	clear_map()
	
	for node_name in DialogData.get_nodes_list(ProjectManager.get_edit_dialog()):
		var type = DialogData.get_node_type(ProjectManager.get_edit_dialog(), node_name)
		var offset = DialogData.get_node_offset(ProjectManager.get_edit_dialog(), node_name)
		add_node_by_type(type, offset, node_name)
	
	for con in DialogData.get_connections_list(ProjectManager.get_edit_dialog()):
		map.connect_node(con["from"], con["from_port"], con["to"], con["to_port"])

func clear_map():
	for con in map.get_connection_list():
		map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
	
	for graph in map.get_children():
		if graph is BasicGraphNode:
			graph.queue_free()

func add_node_by_type(type : int, position : Vector2, node_name : String):
	if type in node_types_list.keys():
		var instance = node_types_list[type].instance()
	
		if instance is BasicGraphNode:
			if node_name != "" && DialogData.is_node_in_dialog(ProjectManager.get_edit_dialog(), node_name):
				instance.name = node_name
			
			instance.update_snap(map.snap_distance)
			instance.offset = position
			
			instance.connect("mouse_entered", self, "set_hovered_node", [instance])
			instance.connect("mouse_exited", self, "unset_hovered_node", [instance])
			
			map.add_child(instance)

func set_hovered_node(node : GraphNode):
	hovered_node = node
	
func unset_hovered_node(node : GraphNode):
	if node == hovered_node: hovered_node = null

func send_connection_info():
	DialogData.set_connection_data(ProjectManager.get_edit_dialog(), map.get_connection_list())

func _on_LocalePicker_item_selected(index : int):
	if index < 0: return
	ProjectManager.set_edit_lang(locale_picker.get_item_text(index))

func _on_DialogeChangeBt_item_selected(index : int):
	if index < 0: return	
	ProjectManager.set_edit_dialog(dialog_picker.get_item_text(index))

func _on_Map_connection_from_empty(to, to_slot, _release_position):
	for con in map.get_connection_list():
		if con["to"] == to && con["to_port"] == to_slot:
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			send_connection_info()
			break

func _on_Map_connection_to_empty(from, from_slot, release_position):
	for con in map.get_connection_list():
		if con["from"] == from && con["from_port"] == from_slot:
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			send_connection_info()
			break

func _on_Map_connection_request(from, from_slot, to, to_slot):
	for con in map.get_connection_list():
		if con["from"] == from && con["from_port"] == from_slot:
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			break
			
	map.connect_node(from, from_slot, to, to_slot)
	send_connection_info()

func _on_Map_disconnection_request(from, from_slot, to, to_slot):
	map.disconnect_node(from, from_slot, to, to_slot)
	send_connection_info()

func _on_Map_node_selected(node):
	pass # Replace with function body.

func _on_Map_node_unselected(node):
	pass

func _on_MapMenu_index_pressed(index):
	var meta = map_menu.get_item_metadata(index)
	
	if meta is FuncRef && meta.is_valid(): meta.call_func()

func _on_AddMenu_id_pressed(id : int):
	var final_position = map.scroll_offset + map.get_local_mouse_position() - (get_global_mouse_position() - map_menu.get_global_rect().position)
	final_position = final_position.snapped(Vector2(map.snap_distance, map.snap_distance))
	
	add_node_by_type(id, final_position, "")

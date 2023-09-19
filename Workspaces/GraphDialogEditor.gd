extends MarginContainer

class_name DialogEditor

var selected_nods 					= []
var current_dialog					= ""
var current_langlage				= ""
var mouse_moved						= Vector2()
var last_mouse_place				= Vector2()
var start_node : GraphElementBase 	= null

var full_size_bt	 		= preload("res://GUI/FullSizeBt.tscn").instance()
var translator_panel		= preload("res://GUI/TranslatorSettings.tscn").instance()

onready var map 			= $Full/EditZone/Map
onready var map_popup 		= $Full/EditZone/MapMenu
onready var add_popup		= $Full/EditZone/MapMenu/AddMenu
onready var blocker			= $Full/EditZone/Blocker
onready var blocker_warning	= $Full/EditZone/Blocker/Warning

onready var dialog_changer	= $Full/Settings/DialogeChangeBt
onready var dialog_label	= $Full/Settings/CurLabel
onready var dialog_actions	= $Full/Settings/DialogOptions

onready var settings_panel	= $Full/Settings
onready var seporator		= $Full/HSeparator
onready var lang_changer	= $Full/Settings/LangChangeBt

signal hide_interface(is_true)
signal change_lang(to_which)
signal update_dependencies

func _ready():
	add_popup.clear()
	add_popup.add_item("Replick")
	add_popup.set_item_metadata(0, Global.DialogType.Replic)
	add_popup.add_item("Options")
	add_popup.set_item_metadata(1, Global.DialogType.Options)
	add_popup.add_item("Varible change")
	add_popup.set_item_metadata(2, Global.DialogType.Varible)
	add_popup.add_item("Branch")
	add_popup.set_item_metadata(3, Global.DialogType.Branch)
	
	dialog_actions.get_popup().connect("index_pressed", self, "_on_MenuButtonMenu_item_selected")
	
	map.get_zoom_hbox().add_child(full_size_bt)
	map.get_zoom_hbox().add_child(translator_panel)
	full_size_bt.connect("toggled", self, "_on_FullSizeBt_toggle")
	
	yield(get_tree(), "idle_frame")
	
	_on_FullSizeBt_toggle(full_size_bt.pressed)
	
	DialogData.connect("refresh_data", self, "on_data_refresh")
	
func on_data_refresh():
	var has_any_dialog = DialogData.get_dialog_list().size() > 0
		
	blocker.visible 		= !has_any_dialog
	dialog_changer.visible 	= has_any_dialog
	dialog_label.visible	= has_any_dialog
	
	dialog_actions.get_popup().set_item_disabled(1, !has_any_dialog)
	dialog_actions.get_popup().set_item_disabled(2, !has_any_dialog)
	
	if current_dialog == "" || !has_any_dialog: return
	
	if DialogData.is_dialog_in_list(current_dialog):
		var nodes_list 			= DialogData.get_nodes_list(current_dialog)
		var connect_list 		= DialogData.get_connections_list(current_dialog)
		var nodes_to_erase		= []
		
		for element in map.get_children():
			if element is GraphElementBase:
				var node_data = DialogData.get_node_info(current_dialog, element.name)
				
				if node_data.keys().size() > 1:
					element.set_settings_from_dict(node_data)
					nodes_list.erase(element.name)
				else:
					nodes_to_erase.append(element)
		
		for node in nodes_list:
			var info = DialogData.get_node_info(current_dialog, node)
			if info.size() > 0:
				add_element_to_map(info["Type"], info)
		
		for con in map.get_connection_list():
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
		
		for node in nodes_to_erase:
			node.queue_free()
		
		for con in connect_list:
			map.connect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			
func add_element_to_map(type : int, element_data = {}) -> GraphElementBase:
	var new_element : GraphElementBase
	
	match type:
		Global.DialogType.Replic:
			new_element = pck_replick.instance()
		Global.DialogType.Options:
			new_element = pck_options.instance()
		Global.DialogType.Branch:
			new_element = pck_branch.instance()
		Global.DialogType.Varible:
			new_element = pck_varible.instance()
		_:
			return null
	
	map.add_child(new_element)
	if element_data.size() > 0: new_element.set_settings_from_dict(element_data)
	DialogData.set_node_in_dialog(current_dialog, new_element.name, new_element.get_replic_info())
	
	new_element.connect("right_clicked", self, "add_actions")
	new_element.connect("lost_slot", self, "_on_child_lost_slot")
	new_element.connect("set_as_start", self, "set_dialog_start")
	new_element.set_dialog_getter(funcref(self, "gather_data_from_current_dialog"))
	
	connect("change_lang", new_element, "on_langlage_change")
	connect("update_dependencies", new_element, "update_dependesy")
	
	if new_element.name in selected_nods: new_element.selected = true
	if new_element.name in DialogData.get_start_nodes_list(current_dialog): new_element.set_as_dialog_start()
	
	translator_panel.connect("mode_changed", new_element, "show_translation_info")
	translator_panel.connect("lang_seted", new_element, "update_panels")
	
	return new_element

func _physics_process(delta):
	if visible && !blocker.visible:
		if Input.is_action_just_released("ui_cancel"):
			print(DialogData.get_dialog(current_dialog))
		
		if Input.is_action_just_pressed("mouse_left_button") || Input.is_action_just_pressed("mouse_right_button"):
			if !Rect2(Vector2(), map_popup.rect_size).has_point(map_popup.get_local_mouse_position()):
				map_popup.hide()
		
		if Input.is_action_just_released("mouse_left_button"):
			emit_signal("update_dependencies")
		
		if Input.is_action_just_released("mouse_right_button"):
			if Rect2(Vector2(-10,-10),Vector2(20, 20)).has_point(mouse_moved):
				show_map_popup()
			else:
				mouse_moved = Vector2()
		
		if Input.is_action_pressed("mouse_right_button"):
			var diff = last_mouse_place - map.get_local_mouse_position()
			map.scroll_offset += diff
			mouse_moved += diff
		
		last_mouse_place = map.get_local_mouse_position()
	
func set_dialog_start(node : GraphElementBase):
	if is_instance_valid(start_node):
		start_node.remove_as_dialog_start()
		DialogData.erase_start_node(current_dialog, start_node.name)
	
	DialogData.add_start_node(current_dialog, node.name)

func clear_map():
	selected_nods.clear()
	
	for com in map.get_connection_list():
		map.disconnect_node(com["from"], com["from_port"], com["to"], com["to_port"])
		
	for node in map.get_children():
		if node is GraphElementBase:
			node.queue_free()
			
	start_node = null

func make_new_dialog(dia_name : String):
	clear_map()
	current_dialog = dia_name
	
	DialogData.make_new_dialog(dia_name)
	
	update_dialog_selector()

func rename_dialog(dia_name : String):
	var old_name = current_dialog
	current_dialog = dia_name
	
	DialogData.rename_dialog(old_name, dia_name)
	
	update_dialog_selector()

func update_dialog_selector():
	Global.update_selector(dialog_changer, dialog_atlas.keys(), false)
	
	for item in dialog_changer.get_item_count():
		if dialog_changer.get_item_text(item) == current_dialog:
			dialog_changer.select(item)
			break
	
func delete_dialog():
	var old_dialog = current_dialog
	
	clear_map()
	
	update_dialog_selector()
	
	if dialog_changer.get_item_count() > 0:
		current_dialog = dialog_changer.get_item_text(0)
	else:
		current_dialog = ""
		
	DialogData.erase_dialog(old_dialog)

func base_map_popup_fill():
	map_popup.clear()
	
	map_popup.add_submenu_item("Add...","AddMenu")
	
func show_map_popup():
	yield(get_tree(), "idle_frame")
	if map_popup.visible: return
	base_map_popup_fill()
	map_popup.rect_position = get_global_mouse_position()
	map_popup.set_as_minsize()
	map_popup.popup()

func add_actions(from_who : GraphElementBase):
	if !from_who.check_map_popup_needness():
		map_popup.hide()
		return
	
	var actions = from_who.get_actions_data()
	
	base_map_popup_fill()

	for act in actions.keys():
		map_popup.add_item(act)
		map_popup.set_item_metadata(map_popup.get_item_count() - 1, actions[act])
	
	map_popup.rect_position = get_global_mouse_position()
	map_popup.set_as_minsize()
	map_popup.popup()

func _on_MapMenu_index_pressed(index):
	var meta = map_popup.get_item_metadata(index) 
	if is_instance_valid(meta) && meta is FuncRef && meta.is_valid():
		meta.call_func()

func _on_AddMenu_id_pressed(id):
	var meta_info = add_popup.get_item_metadata(id)
	
	if meta_info is int:
		var element : GraphElementBase = add_element_to_map(meta_info)
		element.update_snap(map.snap_distance)
		element.offset = map.scroll_offset + map.get_local_mouse_position() - (get_global_mouse_position() - map_popup.get_global_rect().position)
		element.offset = element.offset.snapped(Vector2(map.snap_distance, map.snap_distance))
		
		var count = false
		
		for child in map.get_children():
			if child is GraphElementBase:
				if count < 1:
					count += 1
				else:
					count += 1
					break
		
		if count == 1:
			element.set_as_dialog_start()

func _on_Map_node_selected(node : GraphElementBase):
	if Input.is_action_pressed("multiselect") && node.name in selected_nods:
		yield(get_tree(),"idle_frame")
		selected_nods.erase(node.name)
		node.selected = false
	elif !node.name in selected_nods:
		selected_nods.append(node.name)
		
	translator_panel.call_traslation_update()

func _on_Map_node_unselected(node : GraphElementBase):
	if Input.is_action_pressed("multiselect") && node.name in selected_nods:
		yield(get_tree(),"idle_frame")
		node.selected = true
	else:
		selected_nods.erase(node.name)
	
	translator_panel.call_traslation_update()

func update_connections():
	if DialogData.is_dialog_in_list(current_dialog): DialogData.set_connection_data(current_dialog, map.get_connection_list())

func _on_Map_connection_request(from, from_slot, to, to_slot):
	if from != to:
		for con in map.get_connection_list():
			if con["from"] == from && con["from_port"] == from_slot:
				map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
				break
				
		map.connect_node(from, from_slot, to, to_slot)
		update_connections()

func _on_Map_connection_to_empty(from, from_slot, release_position):
	for con in map.get_connection_list():
		if (con["from"] == from && con["from_port"] == from_slot):
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			update_connections()
			break
			
func _on_Map_connection_from_empty(to, to_slot, release_position):
	for con in map.get_connection_list():
		if (con["to"] == to && con["to_port"] == to_slot):
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			update_connections()
			break

func _on_Map_disconnection_request(from, from_slot, to, to_slot):
	map.disconnect_node(from, from_slot, to, to_slot)
	update_connections()

func force_minimap_update():
	var dummy = GraphNode.new()
	map.call_deferred("add_child", dummy)
	yield(dummy,"tree_entered")
	map.call_deferred("remove_child", dummy)
	yield(dummy,"tree_exited")
	if is_instance_valid(dummy):
		dummy.call_deferred("free")

func _on_Map_child_exiting_tree(node):
	if node is GraphElementBase:
		for con in map.get_connection_list():
			if con ["from"] == node.name:
				map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
		
		update_connections()
		force_minimap_update()
		selected_nods.erase(node.name)

func _on_child_lost_slot(from : String, slot : int):
	for con in map.get_connection_list():
		if con ["from"] == from && con ["from_port"] == slot:
			map.disconnect_node(con["from"], con["from_port"], con["to"], con["to_port"])
			
	update_connections()

func _on_DialogEditor_visibility_changed():
	emit_signal("update_dependencies")

func _on_MenuButtonMenu_item_selected(idx : int):
	match idx:
		0:
			Global.name_something(funcref(self, "make_new_dialog"), "Enter dialog name", dialog_atlas.keys(), true)
		1:
			var all = DialogData.get_dialog_list()
			all.erase(current_dialog)
			
			Global.name_something(funcref(self, "rename_dialog"), "Enter dialog name", all, true)
		2:
			Global.confurm_something(funcref(self, "delete_dialog"), "Are you sure you want to delete this dialog?")

func _on_DialogeChangeBt_item_selected(index):
	current_dialog = dialog_changer.get_item_text(index)
	
	on_data_refresh()

func _on_FullSizeBt_toggle(pressed : bool):
	emit_signal("hide_interface", !pressed)
	settings_panel.visible 	= !pressed
	seporator.visible		= !pressed

func _on_LangChangeBt_item_selected(index):
	while !is_instance_valid(lang_changer): yield(get_tree(), "idle_frame")
	
	current_langlage = lang_changer.get_item_text(index)
	
	var langs = []
	
	for lang in lang_changer.get_item_count():
		if lang_changer.get_item_text(lang) != current_langlage:
			langs.append(lang_changer.get_item_text(lang))
	
	translator_panel.update_lang_list(langs)
	
	emit_signal("change_lang", lang_changer.get_item_text(index))

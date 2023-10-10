extends BaseData

signal dialog_aded
signal dialog_renamed
signal dialog_deleted

signal dialog_node_aded
signal dialog_node_renamed
signal dialog_node_deleted
signal dialog_node_add_as_start
signal dialog_node_removed_as_start

func is_dialog_in_list(dialog_name : String) -> bool:
	return dialog_name in get_dialog_list()

func is_node_in_dialog(dialog_name : String, node : String) -> bool:
	return is_dialog_in_list(dialog_name) && node in get_nodes_list(dialog_name)
	
func is_node_connected(dialog_name : String, from : String, to : String, port = -1) -> bool:
	if !is_node_in_dialog(dialog_name, from) && is_node_in_dialog(dialog_name, to): return false
	
	for con in data[dialog_name]["Connections"]:
		if con["from"] == from && con["to"] == to && (port == -1 || con["from_port"] == port): return true
		
	return false
	
func get_node_enter_connections(dialog_name : String, node_name : String) -> Dictionary:
	var list = {}
	
	if !is_node_in_dialog(dialog_name, node_name): return list
	
	for con in data[dialog_name]["Connections"]:
		if con["to"] == node_name:
			if con["from"] in list.keys():
				if !con["from_port"] in list[con["from"]]:
					list[con["from"]].append(con["from_port"])
			else:
				list[con["from"]] = [con["from_port"]]
	
	return list

func get_empty_dialog() -> Dictionary:
	return {"Start": PoolStringArray([]), "Nodes" : {}, "Connections" : {}, "NodesOffsets" : {}, "NodesTypes" : {}}

func get_dialog_list() -> Array:
	return data.keys()

func get_nodes_list(dialog_name : String) -> Dictionary:
	if is_dialog_in_list(dialog_name): return data[dialog_name]["Nodes"].keys()
	return {}

func get_dialog(dialog_name : String) -> Dictionary:
	if is_dialog_in_list(dialog_name): return data[dialog_name]
	return get_empty_dialog()

func get_connections_list(dialog_name : String) -> Array:
	if is_dialog_in_list(dialog_name): return data[dialog_name]["Connections"]
	return []

func get_start_nodes_list(dialog_name : String) -> PoolStringArray:
	if is_dialog_in_list(dialog_name): return data[dialog_name]["Start"]
	return PoolStringArray([])

func get_node_info(dialog_name : String, node : String) -> Dictionary:
	if !is_node_in_dialog(dialog_name, node): return {}
	
	return data[dialog_name]["Nodes"][node]

func get_node_offset(dialog_name : String, node : String) -> Vector2:
	if !is_node_in_dialog(dialog_name, node): return Vector2()
	return data[dialog_name]["NodesOffsets"][node]

func get_node_type(dialog_name : String, node : String) -> String:
	if !is_node_in_dialog(dialog_name, node): return ""
	return data[dialog_name]["NodesTypes"][node]

func is_key_in_node(dialog_name : String, node_name : String, key : String) -> bool:
	return is_node_in_dialog(dialog_name, node_name) && key in data[dialog_name]["Nodes"][node_name].keys()

func is_node_in_start(dialog_name : String, node_name : String):
	return is_dialog_in_list(dialog_name) && node_name in data[dialog_name]["Start"]

func add_node_to_dialog(dialog_name : String, node_name : String, node_type : String):
	if !is_node_in_dialog(dialog_name, node_name): return
	
	data[dialog_name]["Nodes"][node_name] 	= {}
	data[dialog_name]["NodesOffsets"][node_name] = Vector2()
	data[dialog_name]["NodesTypes"][node_name] = node_type
	
	emit_signal("dialog_node_aded", dialog_name, node_name)

func rename_node_in_dialog(dialog_name : String, old_node : String, new_name : String):
	if !is_node_in_dialog(dialog_name, old_node) || is_node_in_dialog(dialog_name, new_name): return
	
	data[dialog_name]["Nodes"][new_name] = data[dialog_name]["Nodes"][old_node]
	data[dialog_name]["NodesOffsets"][new_name] = data[dialog_name]["NodesOffsets"][old_node]
	data[dialog_name]["NodesTypes"][new_name] = data[dialog_name]["NodesTypes"][old_node]
	data[dialog_name]["Nodes"].erase(old_node)
	data[dialog_name]["NodesOffsets"].erase(old_node)
	data[dialog_name]["NodesTypes"].erase(old_node)
	
	emit_signal("dialog_node_renamed", dialog_name, old_node, new_name)

func add_key_in_node(dialog_name : String, node_name : String, key : String, data):
	if !is_node_in_dialog(dialog_name, node_name) || is_key_in_node(dialog_name, node_name, key): return
	
	data[dialog_name]["Nodes"][node_name][key] = data

func set_key_in_node(dialog_name : String, node_name : String, node_key : String, key_data):
	if !is_key_in_node(dialog_name, node_name, node_key): return
	
	data[dialog_name]["Nodes"][node_name][node_key] = key_data

func get_key_in_node(dialog_name : String, node_name : String, node_key : String) -> Dictionary:
	if !is_key_in_node(dialog_name, node_name, node_key): return {}
	return data[dialog_name]["Nodes"][node_name][node_key]

func delete_all_keys(dialog_name : String, node_name : String):
	if !is_node_in_dialog(dialog_name, node_name): return
	
	data[dialog_name]["Nodes"][node_name] = {}

func delete_keys(dialog_name : String, node_name : String, keys_list : PoolStringArray):
	if !is_node_in_dialog(dialog_name, node_name): return
	
	for key in keys_list:
		data[dialog_name]["Nodes"][node_name].erase(key)

func set_node_in_dialog(dialog_name : String, node_name : String, node_data : Dictionary):
	if !is_node_in_dialog(dialog_name, node_name): return
	
	data[dialog_name]["Nodes"][node_name] = node_data

func set_node_offset(dialog_name : String, node_name : String, offset : Vector2):
	if !is_node_in_dialog(dialog_name, node_name): return
	
	data[dialog_name]["NodesOffsets"][node_name]  = offset

func erase_node_from_dialog(dialog_name : String, node_name : String):
	if !is_node_in_dialog(dialog_name, node_name): return
	
	if is_node_in_start(dialog_name, node_name): erase_start_node(dialog_name, node_name)
	
	data[dialog_name]["Nodes"].erase(node_name)
	data[dialog_name]["NodesOffsets"].erase(node_name)
	
	emit_signal("dialog_node_deleted", dialog_name, node_name)

func add_start_node(dialog_name : String, node_name : String):
	if is_node_in_dialog(dialog_name, node_name) && !is_node_in_start(dialog_name, node_name):
		data[dialog_name]["Start"].append(node_name)
		emit_signal("dialog_node_add_as_start", dialog_name, node_name)
		
func erase_start_node(dialog_name : String, node_name : String):
	if is_node_in_dialog(dialog_name, node_name) && is_node_in_start(dialog_name, node_name):
		data[dialog_name]["Start"].erase(node_name)
		emit_signal("dialog_node_removed_as_start", dialog_name, node_name)

func set_start_nodes_in_dialog(dialog_name : String, nodes_names : PoolStringArray):
	if !is_dialog_in_list(dialog_name): return
	
	for node in data[dialog_name]["Start"]: erase_start_node(dialog_name, node)
	
	for node in nodes_names: add_start_node(dialog_name, node)

func set_connection_data(dialog_name : String, connect_dict : Array):
	if !DialogData.is_dialog_in_list(dialog_name): return
	data[dialog_name]["Connections"] = connect_dict
	
func get_keys_with_key_part(key_part : String, dict_keys : PoolStringArray) -> PoolStringArray:
	var finded_keys : PoolStringArray
	
	for key in dict_keys:
		if key.begins_with(key_part):
			finded_keys.append(key)
	
	return finded_keys

func collect_previous_mood(dialog_name : String, from_node : String, person_id : String, alredy_enter = [], calls = 1) -> Array:
	var enters = get_node_enter_connections(dialog_name, from_node)
	var output = []
	
	if calls > 200: return []
	
	for into in enters.keys():
		if into in alredy_enter: continue
		
		var node_info = get_node_info(dialog_name, enters[into])
		var texture_list = get_keys_with_key_part("Texture", node_info)
		
		for key in texture_list:
			if node_info[key] is Dictionary:
				var texture_atlas : Dictionary = node_info[key]
				if "PersonID" in texture_atlas.keys() && "Mood" in texture_atlas.keys() && texture_atlas["PersonID"] == person_id  && texture_atlas["Mood"] != "<Same>":
					output.append(texture_atlas["Mood"])
					alredy_enter.append(into)
			
		if !is_node_in_start(dialog_name, into):
			output.append_array(collect_previous_mood(dialog_name, into, person_id, alredy_enter, calls + 1))
	
	return output

func make_new_dialog(dialog_name : String):
	if is_dialog_in_list(dialog_name): return
	
	data[dialog_name] = get_empty_dialog()
	
	emit_signal("dialog_aded", dialog_name)
	
func rename_dialog(dialog_name : String, new_dialog_name : String):
	if !is_dialog_in_list(dialog_name) || is_dialog_in_list(new_dialog_name): return
	
	data[new_dialog_name] = data[dialog_name].duplicate(true)
	
	data.erase(dialog_name)
	
	emit_signal("dialog_renamed", dialog_name, new_dialog_name)

func erase_dialog(dialog_name : String):
	if !is_dialog_in_list(dialog_name): return
	
	data.erase(dialog_name)
	
	emit_signal("dialog_deleted", dialog_name)

func _get_export_data() -> Dictionary:
	var export_data = {}
	
	for dialog in get_dialog_list():
		export_data[dialog]["Start"] 		= data[dialog]["Start"]
		export_data[dialog]["Nodes"] 		= data[dialog]["Nodes"]
		export_data[dialog]["Connections"] 	= data[dialog]["Connections"]
	
	return export_data

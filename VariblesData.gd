extends BaseData

#data = {var_name : [varible_type, initial_value]}
	
func set_varible(varible_name : String, initial_value = null):
	match typeof(initial_value):
		TYPE_BOOL, TYPE_INT, TYPE_STRING:
			data[varible_name] = initial_value
		_:
			data[varible_name] = null

func delete_varible(varible_name : String):
	data.erase(varible_name)

func get_varibles_list() ->  Array:
	return data.keys()

func get_initial_value(varible_name : String):
	if !varible_name in get_varibles_list(): return null
	return data[varible_name]


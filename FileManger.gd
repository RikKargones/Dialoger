extends Node

var files_list		 = {}
var project_folder	 = "user://CurProject/"

func get_temp_file_path(file_name : String):
	if file_name in files_list.keys():
		return files_list[file_name][0]
	else:
		return ""

#func checking is file are new (copy to specified folder in temp_folder if it is) and returns it's name in files_list
func register_temp_file(path_to_file : String, path_to_dir : String) -> Array:
	var dir_manager 	= Directory.new()
	var file_handler	= File.new()
	var file : String	= path_to_file.rsplit("/", true, 1)[1]
	
	path_to_dir = path_to_dir.trim_prefix("/")
	path_to_dir = path_to_dir.trim_suffix("/")
	path_to_dir = project_folder + path_to_dir
	
	if dir_manager.file_exists(path_to_file):
		for element in files_list.keys():
			#check all files existance
			if !dir_manager.file_exists(files_list[element][0] + "/" + element):
				files_list.erase(element)
				continue
			#comparing file with files in files_list by MD5 checksum
			#if find same, returns it's name
			if file_handler.get_md5(path_to_file) == file_handler.get_md5(files_list[element][0] + "/" + element):
				files_list[element][1] += 1
				return [element, files_list[element][0]]
		
		#makes unic filename if file name exist
		if file in files_list.keys():
			var count = 1
			var new_file = make_file_numbered(file, str(count))
			
			while new_file in files_list.keys():
				count += 1
				new_file = make_file_numbered(new_file, str(count))
				
			file = new_file
		
		#copies file
		if !dir_manager.dir_exists(path_to_dir):
			dir_manager.make_dir_recursive(path_to_dir)
		
		dir_manager.copy(path_to_file, path_to_dir + "/" + file)
		files_list[file] = [path_to_dir, 1]
		
		return [file, path_to_dir]
	else:
		print("ERROR! File not found...")
		return []

func make_file_numbered(file_name : String, number : String):
	if "." in file_name:
		return file_name.rsplit(".", true, 1)[0] + " (" + number + ")." + file_name.rsplit(".", true, 1)[1]
	else:
		return file_name + " (" + number + ")"

func unregister_temp_file(file_name : String):
	if file_name in files_list.keys():
		var dir_manager = Directory.new()
		
		if dir_manager.file_exists(files_list[file_name][0] + "/" + file_name):
			if files_list[file_name][1] < 2:
				dir_manager.remove(files_list[file_name][0] + "/" + file_name)
				files_list.erase(file_name)
			else:
				files_list[file_name][1] -= 1
		else:
			print("ERROR! File not exist!")
			files_list.erase(file_name)
		
	else:
		print("ERROR! File not registred.")

func export_temp_files(dest : String, is_res = true) -> Dictionary:
	var dir_manager = Directory.new()
	var export_list = {}
	
	dest = dest.trim_suffix("/")
	
	if dir_manager.dir_exists(dest):
		for file in files_list.keys():
			if dir_manager.file_exists(files_list[file][0] + "/" + file): 
				var full_dest = dest + "/" + files_list[file][0].trim_prefix(project_folder)
				
				if !dir_manager.dir_exists(full_dest): dir_manager.make_dir_recursive(full_dest)
				
				dir_manager.copy(files_list[file][0] + "/" + file, full_dest + "/" + file)
				if is_res: export_list[file] = files_list[file][0].replace(project_folder, "res://Dialogs/")
				else: export_list[file] = files_list[file][0].replace(project_folder, dest + "/")
	else:
		print("ERROR! Directory to save not found.")
		
	return export_list

func clear_temp_folder():
	var dir_manager = Directory.new()
	
	for file in files_list.keys():
		if dir_manager.file_exists(files_list[file][0] + "/" + file):
			dir_manager.remove(files_list[file][0] + "/" + file)
	
	files_list.clear()
	
	delete_folder_recursive(project_folder.trim_suffix("/"))
			
func delete_folder_recursive(path : String):
	var dir_manager = Directory.new()
	
	if dir_manager.open(path) == OK:
		dir_manager.list_dir_begin(true)
		var cur_file = dir_manager.get_next()
		
		while cur_file != "":
			if dir_manager.current_is_dir():
				delete_folder_recursive(path + "/" + cur_file)
			else:
				dir_manager.remove(cur_file)
			cur_file = dir_manager.get_next()
		
		dir_manager.list_dir_end()
		dir_manager.remove(path)

extends Node

var files_list		= {}
var resources_list 	= {}
var project_folder	= "user://CurProject/"

func get_external_file_path(file_name : String) -> String:
	if file_name in files_list.keys():
		return files_list[file_name][0]
	else:
		return ""

func get_inside_resource(res_name : String) -> Resource:
	if res_name in resources_list.keys():
		return resources_list[res_name][1]
	return null

#func checking is file are new (copy to specified folder in temp_folder if it is) and returns it's name in files_list
func register_external_file(path_to_file : String, path_to_dir : String) -> Array:
	var dir_manager 	= Directory.new()
	var file_handler	= File.new()
	var file : String	= path_to_file.rsplit("/", true, 1)[1]
	
	path_to_dir = path_to_dir.trim_prefix("/").trim_suffix("/")
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
			var new_file = make_numbered_file(file, str(count))
			
			while new_file in files_list.keys():
				count += 1
				new_file = make_numbered_file(new_file, str(count))
				
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
		
func unregister_external_file(file_name : String):
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

func register_inside_resource(res : Resource, dir_path : String):
	var dir_manager = Directory.new()
	var res_name 	= get_class() + ".tres"
	var number		= 1
	var pr_path 	= project_folder + dir_path.trim_prefix("/")
	
	res.resource_name = res_name
	
	while res.resource_name in resources_list.keys():
		res.resource_name = make_numbered_file(res_name, number)
		number += 1
	
	if !dir_manager.dir_exists(pr_path): dir_manager.make_dir_recursive(pr_path)
	
	if ResourceSaver.save(pr_path.trim_suffix("/") + "/" + res.resource_name, res, ResourceSaver.FLAG_CHANGE_PATH) != OK:
		res.resource_name = ""
	else:
		resources_list[res.resource_name] = [pr_path, res]
		res.connect("changed", self, "resave_inside_resource", [res.resource_name])
	
	return res.resource_name

func resave_inside_resource(res_name : String):
	if res_name in resources_list.keys():
		var dir_manager = Directory.new()
		var pr_path = resources_list[res_name][0].trim_suffix("/")
		
		if !dir_manager.dir_exists(pr_path): dir_manager.make_dir_recursive(pr_path)
		
		if ResourceSaver.save(pr_path + "/" + res_name, resources_list[res_name][1]) != OK:
			Global.popup_error("RESOURCES: Can't resave resource! (" + res_name + ")\nChanges not saved.")

func unregister_inside_resource(res_name : String):
	var dir_manager = Directory.new()
	var file_path	= resources_list[res_name][0].trim_suffix("/") + "/" + res_name
	
	if res_name in resources_list.keys():
		if dir_manager.file_exists(file_path):
			dir_manager.remove(file_path)
		resources_list.erase(res_name)

func make_numbered_file(file_name : String, number : String):
	if "." in file_name:
		return file_name.rsplit(".", true, 1)[0] + " (" + number + ")." + file_name.rsplit(".", true, 1)[1]
	else:
		return file_name + " (" + number + ")"

func export_resources(dest : String):
	var dir_manager = Directory.new()
	var lost_file 	= false
	var cant_save 	= false
	var paths 		= {}
	
	var f_list		= {}
	var r_list		= {}
	
	var full_path 	= ""
	var dir_path 	= ""
	var dest_path 	= ""
	
	for file in files_list.keys():
		full_path = project_folder.trim_suffix("/") + "/" + files_list[file][0].trim_suffix("/") +"/" + file
		dir_path = dest.trim_suffix("/") + "/" + files_list[file][0]
		dest_path = dir_path.trim_suffix("/") + "/" + file
		
		if !dir_manager.file_exists(full_path):
			lost_file = true
			continue
		
		f_list[file] = [files_list[file][0], dest_path, files_list[file][1]]
		paths[full_path] = [dir_path, dest_path]
		
	for res in resources_list.keys():
		full_path = project_folder.trim_suffix("/") + "/" + resources_list[res][0].trim_suffix("/") + "/" + res
		dir_path = dest.trim_suffix("/") + "/" + resources_list[res][0]
		dest_path = dir_path.trim_suffix("/") + "/" + res
		
		if !dir_manager.file_exists(full_path):
			lost_file = true
			continue
		
		r_list[res] = [resources_list[res][0], dest_path]
		paths[full_path] = [dir_path, dest_path]
	
	for path in paths.keys():	
		if !dir_manager.dir_exists(paths[path][0]): dir_manager.make_dir_recursive(paths[path][0])
		if dir_manager.copy(path, paths[path][1]) != OK: cant_save = true
		
	if lost_file: Global.popup_error("EXPORT: Can't find part of saved resources. Not all project file's saved.")
	if cant_save: Global.popup_error("EXPORT: Can't save part of project resources in desired destanation.")
	
	return [f_list, r_list]

#f_list = {file_name : [path_to, absolute_path_to, ref_count]}
#r_list = {res_name : [path_to, absolute_path_to]}
func load_exported_resouces(f_list : Dictionary, r_list : Dictionary):
	var dir_manager = Directory.new()
	var no_file 	= false
	var cant_copy	= false
	var cant_load	= false
	
	for file in f_list.keys():
		if dir_manager.file_exists(f_list[file][1]):
			var full_path = project_folder.trim_suffix("/") + "/" + f_list[file][0].trim_suffix("/") + "/" + file
			if dir_manager.copy(f_list[file][1], full_path) == OK:
				files_list[file] = [f_list[file][0], f_list[file][2]]
				
			else: cant_copy = true
		else: no_file = true
	
	for res in f_list.keys():
		if dir_manager.file_exists(r_list[res][1]):
			var full_path = project_folder.trim_suffix("/") + "/" + r_list[res][0].trim_suffix("/") + "/" + res
			if dir_manager.copy(r_list[res][1], full_path) == OK:
				var loaded_res = ResourceLoader.load(full_path)
				if is_instance_valid(loaded_res):
					loaded_res.resource_name = res
					resources_list[res] = [r_list[res][0], loaded_res]
					
				else: cant_load = true
			else: cant_copy = true
		else: no_file = true
	
	if no_file:		Global.popup_error("LOAD: Part of project files not exist.\nResources not loaded into project.")
	if cant_copy: 	Global.popup_error("LOAD: Can't copy part of saved resourses to temp folder.\nResources not loaded into project.")
	if cant_load: 	Global.popup_error("LOAD: Can't load resource into project.")

func clear_temp_folder():
	var dir_manager = Directory.new()
	
	for file in files_list.keys():
		if dir_manager.file_exists(files_list[file][0] + "/" + file):
			dir_manager.remove(files_list[file][0] + "/" + file)
	
	files_list.clear()
	resources_list.clear()
	
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

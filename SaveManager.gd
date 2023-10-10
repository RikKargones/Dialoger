extends Node

enum META_KEYS {CREATION, SAVE, VERSION}

const project_list_file_path = "user://ProjectList.lst"

var projects = {}

signal save_load_start
signal save_load_finished

signal update_save_list

func popup_file_permission_error():
	Global.popup_error("Looks like programm hasn't have permission to own folder/files!\n Please run this programm again as administrator.\nIf this not help too, leave detalited issue about it on project's GitHub.")

func make_empty_project_list_file():
	var file_manager = File.new()
	
	if file_manager.open(project_list_file_path, File.WRITE) != OK:
		popup_file_permission_error()
		return
	
	file_manager.store_var({})
	file_manager.close()

func save_save_list():
	var file_manager = File.new()
	
	if file_manager.open(project_list_file_path, File.WRITE) == OK:
		file_manager.store_var(projects)
	
	file_manager.close()

func load_save_list():
	var file_manger = File.new()
	
	if !file_manger.file_exists(project_list_file_path):
		make_empty_project_list_file()
		return
	
	if file_manger.open(project_list_file_path, File.READ) != OK:
		popup_file_permission_error()
		return
	
	var file_list = file_manger.get_var()
	
	file_manger.close()
	
	if file_list is Dictionary: update_projects(file_list)
	else: make_empty_project_list_file()

func check_and_fix_project_metadata(project_path : String) -> bool:
	var dir_manager 	= Directory.new()
	var file_manager 	= File.new()
	
	if !dir_manager.file_exists(get_path_to_project_file(project_path)):
		return false
	
	if file_manager.open(get_path_to_project_file(project_path), File.READ) == OK:
		var save_data = file_manager.get_var()
		file_manager.close()
		
		if save_data is Dictionary:
			if "Meta" in save_data.keys() && save_data["Meta"] is Dictionary:
				var metadata = save_data["Meta"]
				var resave_token = false
				
				if !(META_KEYS.CREATION in metadata.keys() && metadata[META_KEYS.CREATION] is Dictionary):
					metadata[META_KEYS.CREATION] = Time.get_datetime_dict_from_system()
					resave_token = true
				if !(META_KEYS.SAVE in metadata.keys() && metadata[META_KEYS.SAVE] is Dictionary):
					metadata[META_KEYS.SAVE] = Time.get_datetime_dict_from_system()
					resave_token = true
				if !(META_KEYS.VERSION in metadata.keys() && metadata[META_KEYS.VERSION] is String):
					return false
					
				if resave_token && file_manager.open(get_path_to_project_file(project_path), File.WRITE):
					save_data["Meta"] = metadata
					file_manager.store_var(save_data)
					file_manager.close()
				
				return true
			else:
				return false
		else:
			return false
	else:
		return false

func update_projects(list_import : Dictionary):
	var dir_manager = Directory.new()
	var file_manger = File.new()
	
	for project in list_import.keys():
		var project_path = list_import[project]
		
		if check_and_fix_project_metadata(project_path):
			projects[project] = project_path

func get_defalut_project_metadata() -> Dictionary:
	return {
		META_KEYS.CREATION 	: 	Time.get_datetime_dict_from_system(),
		META_KEYS.SAVE		: 	Time.get_datetime_dict_from_system(),
		META_KEYS.VERSION	: 	Defaluts.version,
		}

func get_project_metadata(project_path : String) -> Dictionary:
	var file_manager 	= File.new()
	var full_path		= get_path_to_project_file(project_path)
	var meta
	
	if check_and_fix_project_metadata(project_path) && file_manager.open(full_path, File.READ) == OK:
		meta = file_manager.get_var()["Meta"]
		file_manager.close()
	else:
		meta = get_defalut_project_metadata()
		
	return meta

func add_project(project_name : String, path_to_folder : String) -> String:
	var dir_manager 	= Directory.new()
	var file_manager 	= File.new()
	var full_path		= get_path_to_project_file(path_to_folder)
	
	if project_name in projects.keys():
		var count = 1
		var full_name = project_name + " " + str(count)
		while full_name in projects.keys():
			count += 1
			full_name = project_name + " " + str(count)
		project_name = full_name
	
	if dir_manager.dir_exists(path_to_folder):
		FileManger.delete_folder_recursive(path_to_folder)
	
	dir_manager.make_dir_recursive(path_to_folder)
	
	if file_manager.open(full_path, File.WRITE) == OK:
		file_manager.close()
		ProjectManager.clear_project()
		ProjectManager.project_name = project_name
		projects[project_name] = path_to_folder
		save_current_project()
	else:
		Global.popup_error("Can't save project data! Try run programm as administrator.")
		project_name = ""
	
	file_manager.close()
	
	return project_name

func get_path_to_project_file(folder : String):
	return folder.trim_suffix("/") + "/ProjectData.dpd"

func save_project_as(project_name : String, path_to_folder : String):
	if project_name in projects.keys() && path_to_folder == projects[project_name]: return
	
	var old_project = ProjectManager.project_name
	
	ProjectManager.project_name = add_project(project_name, path_to_folder)
	
	if ProjectManager.project_name != "":
		save_current_project()
	else:
		ProjectManager.project_name = old_project

func save_current_project():
	if !ProjectManager.project_name in projects.keys(): return
	
	var project_path : String 	= projects[ProjectManager.project_name]
	var metadata : Dictionary	= get_project_metadata(project_path)
	var dir_manager : Directory	= Directory.new()
	var file_manager : File		= File.new()
	
	metadata[META_KEYS.SAVE] 	= Time.get_datetime_dict_from_system()
	metadata[META_KEYS.VERSION] = Defaluts.version
	
	if dir_manager.dir_exists(project_path):
		FileManger.delete_folder_recursive(project_path)
	
	dir_manager.make_dir_recursive(project_path)
	
	if file_manager.open(get_path_to_project_file(project_path), File.WRITE) == OK:
		var save_dict = {
			"Meta"		: metadata,
			"Res"		: FileManger.export_resources(project_path),
			"Fonts"		: FontsData._get_save_data(),
			"Vars" 		: VariblesData._get_save_data(),
			"Langs"		: LangluageData._get_save_data(),
			"Persons"	: PersonsData._get_save_data(),
			"Dialogs"	: DialogData._get_save_data()
		}
		file_manager.store_var(save_dict)
	else:
		Global.popup_error("Looks like Dialoger can't save project's file.\nTry run programm as administrator.")
	
	file_manager.close()
	
func load_project(project_name : String):
	if project_name in projects.keys(): return
	
	var dir_manager		: Directory = Directory.new()
	var file_manager	: File		= File.new()
	var project_path 	: String 	= projects[project_name]
	
	ProjectManager.clear_project()
	ProjectManager.project_name = project_name
	
	if file_manager.open(get_path_to_project_file(project_path), File.READ) == OK:
		var save_data = file_manager.get_var()
		
		if save_data is Dictionary:
			for key in save_data.keys():
				var data_part = save_data[key]
				
				match key:
					"Fonts", "Vars", "Langs", "Persons", "Dialogs", "Meta":
						if data_part is Dictionary: continue
					"Res":
						if data_part is Array && data_part.size() == 2:
							FileManger.load_exported_resouces(data_part[0], data_part[1])
					"Meta":
						check_and_fix_project_metadata(project_path)
					"Fonts":
						FontsData._set_data_from_save(data_part)
					"Vars":
						VariblesData._set_data_from_save(data_part)
					"Langs":
						LangluageData._set_data_from_save(data_part)
					"Persons":
						PersonsData._set_data_from_save(data_part)
					"Dialogs":
						DialogData._set_data_from_save(data_part)
		
	file_manager.close()
	

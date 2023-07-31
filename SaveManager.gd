extends Node

const project_list_file_path = "user://ProjectList.lst"

var project_paths = []

signal save_load_start
signal save_load_finished

signal update_save_list

var var_update_funcref 	: FuncRef
var font_update_funcref	: FuncRef
var lang_update_funcref	: FuncRef
var pers_update_funcref	: FuncRef
var dial_update_funcref	: FuncRef

func _ready():
	var dir_manager 	= Directory.new()
	var file_manager 	= File.new()
	
	if dir_manager.file_exists(project_list_file_path):
		if file_manager.open(project_list_file_path, File.READ) == OK:
			project_paths = file_manager.get_var()
			if project_paths == null: project_paths = []
			else: emit_signal("update_save_list")
		else:
			Global.popup_error("Someting wrong with project list file!\nFile exist, but can't be opend!")
		
		file_manager.close()
	else:
		save_project_list()

func save_project_list(add_path = ""):
	var file_manager = File.new()
	
	if add_path != "":
		project_paths.append(add_path)
	
	emit_signal("update_save_list", project_paths.duplicate())
	
	if file_manager.open(project_list_file_path, File.WRITE) == OK:
		file_manager.store_var(project_paths)
	else:
		Global.popup_error("Can't save project list.")
		
	file_manager.close()

func create_project(path : String):
	var dir_manager = Directory.new()
	var path_to_folder = path.rsplit("/", true, 1)[0]
	
	if !dir_manager.dir_exists(path_to_folder): dir_manager.make_dir_recursive(path_to_folder)
	
	if dir_manager.open(path_to_folder) == OK:
		ProjectManager.clear_project()
		save_project_as(path)
		load_project(path)
	else:
		Global.popup_error("Can't open folder.\nWrong path or unacessable directory.")

func show_export_popup():
	pass

func show_save_popup():
	pass

func save_project():
	var dir_manager = Directory.new()
	
	if dir_manager.dir_exists(ProjectManager.project_folder):
		var file_manager = File.new()
		if file_manager.open(ProjectManager.project_folder + "/" + ProjectManager.project_name + ".dpf", File.WRITE) == OK:
			FileManger.delete_folder_recursive(ProjectManager.project_folder + "/Res")
			ProjectManager.collect_project_info()
			
			var paths = FileManger.export_temp_files(ProjectManager.project_folder, false)
			var fonts_saved = ProjectManager.fonts_atlas.duplicate(true)
			var persons_saved = ProjectManager.persons_atlas.duplicate(true)
			var lang_fonts_saved = ProjectManager.font_lang_atlas.duplicate(true)
			var save_date = Time.get_date_dict_from_system()
			var save_time = Time.get_time_string_from_system()
			
			for font in fonts_saved.keys():
				fonts_saved[font] = paths[fonts_saved[font][1]] + "/" + fonts_saved[font][1]
				
			for person in persons_saved.keys():
				for mood in persons_saved[person]["Moods"].keys():
					var mood_file = persons_saved[person]["Moods"][mood][1]
					persons_saved[person]["Moods"][mood] = paths[mood_file] + "/" + mood_file
					
			for lang in lang_fonts_saved.keys():
				var transl : Translation = lang_fonts_saved[lang][1]
				var messeges = {}
				
				for msg in transl.get_message_list():
					messeges[msg] = transl[transl.get_message(msg)]
				
				lang_fonts_saved[lang][1] = [transl.locale, messeges]
			
			file_manager.store_var({
				"CreateDate" 	: ProjectManager.project_create_date,
				"CreateTime" 	: ProjectManager.project_create_time,
				"CreateVersion"	: ProjectManager.project_create_version,
				"SaveDate" 		: save_date,
				"SaveTime" 		: save_time,
				"SaveVersion"	: Defaluts.version
				})
			
			file_manager.store_var([
				Defaluts.max_lines,
				Defaluts.max_symbols_per_line,
				Defaluts.main_lang,
				Defaluts.preview_miror_left,
				Defaluts.preview_miror_center,
				Defaluts.preview_miror_right
				])
			
			file_manager.store_var(fonts_saved)
			file_manager.store_var(lang_fonts_saved)
			file_manager.store_var(persons_saved)
			file_manager.store_var(ProjectManager.varibles_atlas)
			file_manager.store_var(ProjectManager.dialog_atlas)
		else:
			Global.popup_error("Project file can't be saved for some reason!\nUse \"Save Project As...\" instead.")
		
		file_manager.close()
	else:
		Global.popup_error("Project folder is not reachble! Use \"Save Project As...\" instead.")
	
func save_project_as(path : String):
	ProjectManager.project_folder 			= path.rsplit("/", true, 1)[0]
	ProjectManager.project_name 			= path.rsplit("/", true, 1)[1].rsplit(".dpf", true, 1)[0]
	
	ProjectManager.project_create_date 	= Time.get_date_dict_from_system()
	ProjectManager.project_create_time 	= Time.get_time_string_from_system()
	
	ProjectManager.project_create_version 	= Defaluts.version
	
	save_project()
	save_project_list(path)

func load_project(path : String):
	var file_manager = File.new()
	
	if file_manager.open(path, File.READ) == OK:
		ProjectManager.clear_project()
		yield(get_tree(), "idle_frame")
		
		var save_info 					= file_manager.get_var()
		var def_info					= file_manager.get_var()
		ProjectManager.fonts_atlas 		= file_manager.get_var()
		ProjectManager.font_lang_atlas 	= file_manager.get_var()
		ProjectManager.persons_atlas	= file_manager.get_var()
		ProjectManager.varibles_atlas	= file_manager.get_var()
		ProjectManager.dialog_atlas		= file_manager.get_var()
		
		for key in save_info.keys():
			match key:
				"CreateDate" :
					ProjectManager.project_create_date = save_info[key]
				"CreateTime" :
					ProjectManager.project_create_time = save_info[key]
				"CreateVersion"	:
					ProjectManager.project_create_version = save_info[key]
		
		Defaluts.max_lines 				= def_info[0]
		Defaluts.max_symbols_per_line 	= def_info[1]
		Defaluts.main_lang 				= def_info[2]
		Defaluts.preview_miror_left 	= def_info[3]
		Defaluts.preview_miror_center 	= def_info[4]
		Defaluts.preview_miror_right 	= def_info[5]
		
		ProjectManager.project_name = path.get_file().rsplit(".", true, 1)[0]
		ProjectManager.project_folder = path.get_basename().rsplit("/",true,1)[0]
		update_persons()
	else:
		Global.popup_error("Can't load project file.")

func update_persons():
	emit_signal("save_load_start")
	var_update_funcref.call_func()
	font_update_funcref.call_func()
	lang_update_funcref.call_func()
	pers_update_funcref.call_func()
	dial_update_funcref.call_func()
	emit_signal("save_load_finished")

func delete_path(path : String):
	project_paths.erase(path)
	save_project_list()

func show_load_popup():
	pass

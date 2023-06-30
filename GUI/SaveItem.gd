extends PanelContainer

enum Weeknames {SUN, MON, TUE, WEN, THU, FRI, SAT}

onready var save_name_line		= $Main/SaveInfo/SaveName
onready var path_line 			= $Main/SaveInfo/Dates/Path
onready var creation_date_line 	= $Main/SaveInfo/Dates/CreationDate
onready var save_date_line		= $Main/SaveInfo/Dates/SaveDate

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		check_file_existance()

func set_savefile(path : String):
	var dir_manager = Directory.new()
	var file_manager = File.new()
	
	if dir_manager.file_exists(path) && file_manager.open(path, File.READ) == OK:
		var file_info = file_manager.get_var()
		
		save_name_line.text = path.rsplit("/", true, 1)[1].rsplit(".", true, 1)[0]
		
		creation_date_line.text = "?"
		save_date_line.text 	= "?"
		
		if file_info is Dictionary:
			for key in file_info.keys():
				match key:
					"CreateDate":
						var date_dict = file_info[key]
						var full_text = Weeknames.keys()[date_dict["weekday"]] + ", "
						if date_dict["day"] < 10: full_text += "0"
						full_text += str(date_dict["day"]) + "."
						if date_dict["month"] < 10: full_text += "0"
						full_text += str(date_dict["month"]) + "."
						full_text += str(date_dict["year"])
						creation_date_line.text = full_text + " "
					"CreateTime":
						var time_str = file_info[key]
						creation_date_line.text += time_str.rsplit(":",true,1)[0]
					"CreateVersion":
						creation_date_line.text += " ("+ str(file_info[key]) +")"
					"SaveDate":
						var date_dict = file_info[key]
						var full_text = Weeknames.keys()[date_dict["weekday"]] + ", "
						if date_dict["day"] < 10: full_text += "0"
						full_text += str(date_dict["day"]) + "."
						if date_dict["month"] < 10: full_text += "0"
						full_text += str(date_dict["month"]) + "."
						full_text += str(date_dict["year"])
						save_date_line.text = full_text + " "
					"SaveTime":
						var time_str = file_info[key]
						save_date_line.text += time_str.rsplit(":",true,1)[0]
					"SaveVersion":
						save_date_line.text += " ("+ str(file_info[key]) +")"						
					
			path_line.text = path.rsplit("/", true, 1)[0]
		else:
			print("Save information is broken!")
			queue_free()
	else:
		go_delete()
	
	file_manager.close()

func get_savefile_path() -> String:
	return path_line.text + "/" + save_name_line.text + ".dpf"

func _on_LoadBt_pressed():
	SaveManager.load_project(get_savefile_path())

func _on_FindBt_pressed():
	var dir_m = Directory.new()
	
	if dir_m.dir_exists(ProjectSettings.globalize_path(path_line.text)):
		OS.shell_open(ProjectSettings.globalize_path(path_line.text))

func _on_DelBt_pressed():
	Global.confurm_something(funcref(self, "go_delete"), "Are you sure?\nIt's only deletes project from saves list.")

func check_file_existance():
	var dir_manager = Directory.new()
	
	if !dir_manager.file_exists(get_savefile_path()): go_delete()

func go_delete():
	SaveManager.delete_path(get_savefile_path())
	queue_free()

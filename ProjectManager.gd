extends Node

var project_name			= ""
var project_folder			= ""
var project_create_date		= Time.get_date_dict_from_system()
var project_create_time		= Time.get_time_string_from_system()
var project_create_version	= Defaluts.version
var project_unsaved			= false

var current_edit_lang 		= "English"
var current_compare_lang 	= ""

var curent_edit_dialog		= ""

signal clear_project

signal edit_lang_changed
signal compare_lang_changed
signal dialog_changed
	
func clear_project():
	project_name 	= ""
	project_folder 	= ""
	
	emit_signal("clear_project")
	
	project_unsaved = false

func set_edit_lang(lang_name : String):
	if LangluageData.is_locale_in_list(lang_name):
		current_edit_lang = lang_name
		emit_signal("edit_lang_changed")
	
func get_edit_lang() -> String:
	return current_edit_lang
	
func set_compare_lang(lang_name : String):
	if LangluageData.is_locale_in_list(lang_name):
		current_compare_lang = lang_name
		emit_signal("compare_lang_changed")
	
func get_compare_lang() -> String:
	return current_compare_lang
	
func set_edit_dialog(dialog_name : String):
	if DialogData.is_dialog_in_list(dialog_name):
		curent_edit_dialog = dialog_name
	
func get_edit_dialog() -> String:
	return curent_edit_dialog

func data_is_same(old_data, new_data) -> bool:
	if typeof(old_data) != typeof(new_data): return false
	elif old_data is Dictionary && new_data.hash() != old_data.hash(): return false
	elif old_data != new_data: return false
	
	return true

func export_data(args = ["user://TestExport", false]):
	var path_to_save = args[0]
	var non_res = args[1]
	
	project_unsaved = false
	
	var dir_manager 		= Directory.new()	
	var main_path			= path_to_save.trim_suffix("/") + "/Dialogs"
	var export_sum : float 	= 7.0
	var export_step 		= 0

	export_sum += FontsData.get_fonts_list().size()
	export_sum += PersonsData.get_persons_list().size()
	export_sum += LangluageData.get_locales_list().size()
	export_sum += VariblesData.get_varibles_list().size()
	export_sum += DialogData.get_dialog_list().size()
	export_sum += FileManger.files_list.size()
	
	export_step = 100/export_sum
	
	Global.call_deferred("start_export_status", "Creating main folder in " + main_path + "...")
	
	if dir_manager.dir_exists(main_path):
		FileManger.delete_folder_recursive(main_path)
	
	dir_manager.make_dir_recursive(main_path)
	
	if dir_manager.dir_exists(main_path):
		Global.update_export_status(export_step, "Exporting external resourses...")
		var ext_res_list = FileManger.export_temp_files(main_path, !non_res)
		var file_handler = File.new()
		Global.call_deferred("update_export_status", export_step * FileManger.files_list.size(), "Exporting empty DialogDispetcher...")
		
		var dir_error = dir_manager.copy("res://DialogDispetcher/DialogDispetcher.gd", main_path + "/DialogDispetcher.gd")
		var file_error = file_handler.open(main_path + "/DialogDispetcher.gd", File.READ)
		
		if dir_error == OK && file_error == OK:
			var dd_code = file_handler.get_as_text()
	
		file_handler.close()
		
	Global.call_deferred("end_export_status")

func form_codelike_string(varible):
	var final_string = ""
	match typeof(varible):
		TYPE_ARRAY:
			final_string += "["
			for part in varible:
				if !final_string.ends_with("["): final_string += ", "
				final_string += form_codelike_string(part)
			final_string += "]"
		TYPE_DICTIONARY:
			final_string += "{"
			for key in varible.keys():
				if !final_string.ends_with("{"): final_string += ", "
				final_string += "\"" + key + "\" : " + form_codelike_string(varible[key])
			final_string += "}"
		TYPE_STRING:
			final_string += "\"" + varible.replace("\n", "\\n") + "\""	
		TYPE_VECTOR2:
			final_string += "Vector2" + str(varible)
		TYPE_BOOL:
			if varible: final_string += "true"
			else: final_string += "false"
		_:
			final_string += str(varible)
		
	return final_string

func find_and_replace_line(substr : String, by : String, text : String):
	var pos = text.find(substr)
	var line = ""
	
	if pos != -1:
		line = text.substr(pos).split("\n", true, 1)[0]
		text = text.replace(line, by)

	return text

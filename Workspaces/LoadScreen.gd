extends MarginContainer

onready var new_popup 			= $Control/NewProjectPopup
onready var new_popup_name 		= $Control/NewProjectPopup/Margin/List/NameLine/NameEdit
onready var new_popup_path		= $Control/NewProjectPopup/Margin/List/PathLine/PathFiled

onready var save_list 			= $Recent/ScrollContainer/MarginContainer/RecentList

var popup_path = ""

var save_item_pck = preload("res://GUI/SaveItem.tscn")

func _ready():
	SaveManager.connect("update_save_list", self, "update_list", [], CONNECT_DEFERRED)
	new_popup.get_ok().disabled = true
	set_directory("")
	update_list(SaveManager.project_paths.duplicate())

func update_list(paths : Array):
	for child in save_list.get_children():
		if child.has_method("get_savefile_path"):
			if child.get_savefile_path() in paths:
				paths.erase(child.get_savefile_path())
			else:
				child.queue_free()
	
	for path in paths:
		create_save(path)

func create_save(path : String):
	var new_save_item = save_item_pck.instance()
	save_list.add_child(new_save_item)
	new_save_item.set_savefile(path)
	
func _on_NewProjectBt_pressed():
	new_popup_name.text = ""
	new_popup_path.text = ""
	popup_path = ""
	new_popup.popup_centered()

func _on_NewProjectPopup_confirmed():
	if ProjectManager.project_name != "": SaveManager.save_project()
	SaveManager.create_project(new_popup_path.text)

func _on_SelectBt_pressed():
	Global.open_file(funcref(self, "set_path"), [], "Choose directory", FileDialog.MODE_OPEN_DIR)

func set_path(path : String):
	popup_path = path
	_on_NameEdit_text_changed(new_popup_name.text)

func set_directory(path : String):
	new_popup_path.text = path

func _on_NameEdit_text_changed(new_text : String):
	var old_car_pos = new_popup_name.caret_position
	var dir_manager = Directory.new()
	
	new_text = new_text.strip_edges(true, false).replace(" ", "_").replace("__", "_").substr(0, 20)
	new_popup_name.text = Global.retrain_only_latin_and_nums(new_text, true)
	new_popup_name.caret_position = old_car_pos
	
	if popup_path == "":
		if new_popup_name.text == "":
			if dir_manager.dir_exists(Defaluts.defalut_project_folder + "/UntitledProject"):
				var incriment = 1
				
				while dir_manager.dir_exists(Defaluts.defalut_project_folder + "/UntitledProject" + str(incriment)):
					incriment += 1
				
				set_directory(Defaluts.defalut_project_folder + "/UntitledProject" + str(incriment) + "/UntitledProject" + str(incriment) + ".dpf")
			else:
				set_directory(Defaluts.defalut_project_folder + "/UntitledProject/UntitledProject.dpf")
		else:
			set_directory("user://Projects/" + new_popup_name.text + "/" + new_popup_name.text + ".dpf")
	elif new_popup_name.text == "":
		set_directory(popup_path + "/UntitledProject.dpf")
	else:
		set_directory(popup_path + "/" + new_popup_name.text + ".dpf")
	
	if new_popup_name.text in ["", "_", " "]:
		new_popup.get_ok().disabled = true
	elif dir_manager.dir_exists(new_popup_path.text.rsplit("/",true,1)[0]):
		if dir_manager.open(new_popup_path.text.rsplit("/",true,1)[0]) == OK:
			dir_manager.list_dir_begin(true, true)
			var file = dir_manager.get_next()
			new_popup.get_ok().disabled = (file != "")
		else:
			new_popup.get_ok().disabled = true
	else:
		new_popup.get_ok().disabled = false

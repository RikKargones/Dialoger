extends Node

enum DialogePictureAligment		 	{Left, Center, Right}
enum DialogType						{Replic, Options, Varible, Branch}

onready var error_popup 			= preload("res://Popups/ErrorDialog.tscn")
onready var confurm_dialog_popup	= preload("res://Popups/ConfirmationDialog.tscn")
onready var confurm_name_popup		= preload("res://Popups/FiledWithConformation.tscn")

onready var export_status			= preload("res://Popups/ExportStatus.tscn").instance()
onready var file_open_popup			= preload("res://Popups/FileDialog.tscn").instance()

var active_popups = []

var file_catcher 	: FuncRef
var confurm_catcher : FuncRef
var name_catcher	: FuncRef

var export_thread 	: Thread

signal block_screen
signal unblock_screen

func _ready():
	var root = get_tree().current_scene
	
	OS.low_processor_usage_mode = true
	#OS.window_fullscreen = true
	
	export_status.visible = false
	
	root.add_child(file_open_popup)
	root.add_child(export_status)
	
	file_open_popup.owner 		= root
	
	file_open_popup.connect("file_selected", 	self, "return_path_to_file")
	file_open_popup.connect("files_selected", 	self, "return_path_to_file")
	file_open_popup.connect("dir_selected", 	self, "return_path_to_file")

func _physics_process(delta):
	if Input.is_action_just_released("ui_cancel"):
		start_export("user://TestExport")
	
func start_export(path_to_save : String, for_preview = false):
	if is_instance_valid(export_thread) && export_thread.is_active():
		return ERR_BUSY
	
	export_thread = Thread.new()
	export_thread.start(ProjectManager, "export_data", [path_to_save, for_preview])
	return OK

func open_file(function_catcher : FuncRef, filters : PoolStringArray, dialog_title : String, mode = FileDialog.MODE_OPEN_FILE):
	file_catcher = function_catcher
	file_open_popup.clear_filters()
	file_open_popup.window_title = dialog_title
	
	for filter in filters:
		file_open_popup.add_filter(filter)
		
	file_open_popup.mode = mode
		
	file_open_popup.popup_centered()

func add_active_popup(popup : WindowDialog):
	active_popups.append(popup)
	popup.connect("popup_hide", self, "update_active_popups")
	
func update_active_popups():
	for popup in active_popups:
		if !is_instance_valid(popup):
			active_popups.erase(popup)

func popup_error(text : String):
	var popup = error_popup.instance()
	get_tree().current_scene.add_child(popup)
	popup.set_text_centred(text)
	popup.set_as_minsize()
	popup.popup_centered()
	add_active_popup(popup)

func confurm_something(func_catcher : FuncRef, text : String):
	var popup = confurm_dialog_popup.instance()
	get_tree().current_scene.add_child(popup)
	popup.set_information(func_catcher, text)
	add_active_popup(popup)
	
func name_something(func_catcher : FuncRef, message_text : String, unacessable_names : Array = [], no_spaces = false):
	var popup = confurm_name_popup.instance()
	get_tree().current_scene.add_child(popup)
	popup.set_information(func_catcher, message_text, unacessable_names, no_spaces)
	popup.set_as_minsize()
	popup.popup_centered()
	add_active_popup(popup)

func show_export_status():
	emit_signal("block_screen")
	export_status.visible = true

func end_export_status():
	if is_instance_valid(export_thread):
		export_thread.wait_to_finish()
	export_status.visible = false
	emit_signal("unblock_screen")
	
func start_export_status(status : String):
	export_status.set_percent(0.0)
	show_export_status()
	
func update_export_status(step_percent : float, status : String):
	export_status.progress_percent(step_percent)
	export_status.set_status(status)

func return_path_to_file(path):
	if is_instance_valid(file_catcher) && file_catcher.is_valid():
		file_catcher.call_func(path)

func retrain_only_latin_and_nums(text : String, no_spaces = false):
	var regex 		= RegEx.new()
	var new_text	= ""
	
	if text.length() == 1: regex.compile("[A-Za-z]")
	elif no_spaces: regex.compile("[A-Za-z]+[A-Za-z0-9_]+")
	else: regex.compile("[A-Za-z]+[A-Za-z0-9_ ]+")
	
	for valid in regex.search_all(text):
		new_text += valid.get_string()
	
	return new_text

func update_selector(selector : OptionButton, item_array : PoolStringArray, select_old = true):
	var old_name = selector.text
	
	selector.clear()
	
	for nm in item_array:
		selector.add_item(nm)
		
	if select_old:
		for idx in selector.get_item_count():
			if selector.get_item_text(idx) == old_name:
				selector.select(idx)
				break

func add_name_meta(nodes : Array, custom_name_get : String = "", backwards_check = false):
	var name_array = {}
	
	for node in nodes.size():
		var who = node
		
		if backwards_check: who = nodes.size() - node - 1
		
		if custom_name_get != "":
			name_array[nodes[who].call(custom_name_get)] = nodes[who]
		else:
			name_array[nodes[who]] = nodes[who]
	
	for node in nodes:
		node.set_meta("Names", name_array)

func is_someone_has_my_name(node, my_name):
	if node.has_meta("Names"):
		var names = node.get_meta("Names")
		
		if my_name in names.keys():
			if names[my_name] != node:
				return true
				
	return false

extends Control

#Dialog Database
enum dialog_names 	{}
enum varible_names 	{}
enum langs_names	{}
enum fonts_names	{}

const database_path = ""

var current_lang = ""

var bool_var_atlas 	= {}
var int_var_atlas 	= {}
var str_var_atlas	= {}

var dialogs_atlas 	= {}
var persons_atlas	= {}
var font_atlas		= {}
var lang_atlas		= {}

var active_dialogs	= []

#Signals
signal dd_started(dialog_name)
signal dd_debug_message(text)
signal dd_ended(dialog_name)

signal dd_lang_changed(to)
signal dd_varible_changed(varible_name)

#Custom Signals
#С_SIGNALS_EXPORT_MARK

func _init():
	var file_manager 	= File.new()
	
	if file_manager.open(database_path, File.READ) != OK:
		print("Someting wrong with file path to database! Information not loaded.")
	else:
		font_atlas 		= file_manager.get_var()
		lang_atlas 		= file_manager.get_var()
		persons_atlas 	= file_manager.get_var()
		bool_var_atlas	= file_manager.get_var()
		int_var_atlas	= file_manager.get_var()
		str_var_atlas	= file_manager.get_var()
		dialogs_atlas	= file_manager.get_var()
		
		for font in font_atlas.keys():
			font_atlas[font] = ResourceLoader.load(font_atlas[font])
	
	file_manager.close()

func update_active_dialogs_list():
	for dialog in active_dialogs:
		if !is_instance_valid(dialog):
			active_dialogs.erase(dialog)

func get_font_by_name(font_name : String):
	if font_name in font_atlas.keys():
		return font_atlas[font_name]
	return null

func create_dialog(dialog_name, oneshot = false) -> DialogProcessor:
	if dialog_name is String && dialog_name in dialogs_atlas.keys():
		var new_process = DialogProcessor.new()
		new_process.dialog_dispetcher = self
		active_dialogs.append(new_process)
		new_process.connect("dp_deleted", self, "update_active_dialogs_list")
		new_process.set_dialog_info(dialog_names[dialog_name], current_lang, oneshot)
		return new_process
	if dialog_name is int && dialog_name in dialog_names.values():
		var new_process = DialogProcessor.new()
		new_process.dialog_dispetcher = self
		active_dialogs.append(new_process)
		new_process.connect("dp_deleted", self, "update_active_dialogs_list")
		new_process.set_dialog_info(dialog_name, current_lang, oneshot)
		return new_process
	else:
		return null

func get_bool_var_atlas():
	return bool_var_atlas

func get_int_var_atlas():
	return int_var_atlas

func get_str_var_atlas():
	return str_var_atlas

func get_varible_name(id_in_enum : int) -> String:
	for var_name in varible_names.keys():
		if varible_names[var_name] == id_in_enum:
			return str(var_name)
	return ""

func get_varible(varible_name : int):
	var var_name = get_varible_name(varible_name)
	if var_name in bool_var_atlas.keys():	return bool_var_atlas[var_name]
	if var_name in int_var_atlas.keys():	return int_var_atlas[var_name]
	if var_name in str_var_atlas.keys():	return str_var_atlas[var_name]
	return null
	
func get_lang_id_by_name(lang_name : String) -> int:
	if lang_name in langs_names.keys():
		return langs_names[lang_name]
	return -1

func set_varible(varible_name : int, value):
	var var_name = get_varible_name(varible_name)
	set_varible_by_name(var_name, value)

func set_varible_by_name(var_name : String, value):
	if var_name in bool_var_atlas.keys() && value is bool:		bool_var_atlas[var_name] 	= value
	elif var_name in int_var_atlas.keys() && value is int:		int_var_atlas[var_name] 	= value
	elif var_name in str_var_atlas.keys() && value is String:	str_var_atlas[var_name] 	= value

func update_varibles(bool_dict : Dictionary, int_dict : Dictionary, str_dict : Dictionary):
	for bool_var in bool_var_atlas.keys():
		if bool_var in bool_dict.keys() && bool_dict[bool_var] is bool:
			bool_var_atlas[bool_var] = bool_dict[bool_var]
	
	for int_var in int_var_atlas.keys():
		if int_var in int_dict.keys() && int_dict[int_var] is int:
			int_var_atlas[int_var] = int_dict[int_var]
	
	for str_var in str_var_atlas.keys():
		if str_var in str_dict.keys() && str_dict[str_var] is String:
			str_var_atlas[str_var] = str_dict[str_var]

func update_varibles_unsorted(unsorted_info : Dictionary):
	for info in unsorted_info.keys():
		set_varible(info, unsorted_info[info])

func print_to_panel(info : String):
	emit_signal("dd_debug_message", "> " + info)

func change_language(lang_id : int):
	if lang_id in langs_names.values():
		current_lang = langs_names.keys()[lang_id]
		for dialog in active_dialogs:
			if is_instance_valid(dialog): dialog.change_langluage(current_lang)

extends MarginContainer

class_name BasicGraphBlock

export (NodePath) 	var person_picker
export (NodePath) 	var font_picker
export (NodePath) 	var mood_picker
export (NodePath) 	var align_picker

var dialog_node_name 	= ""
var dialog_node_key		= ""
var dialog_base_index	= Defaluts.DIALOG_BLOCKS.NONE

var person_id 			= ""
var font_name			= ""
var mood_id				= 0
var align				= 0

var msgs				= []

signal person_picked
signal font_picked
signal mood_picked
signal align_picked

signal msg_registred
signal msg_unregistred

func _ready():
	DialogData.connect("dialog_node_renamed", self, "on_node_rename")
	
	var person_picker_node 	= get_node_or_null(person_picker)
	var font_picker_node	= get_node_or_null(font_picker)
	var mood_picker_node	= get_node_or_null(mood_picker)
	var align_picker_node	= get_node_or_null(align_picker)
	
	if is_instance_valid(person_picker_node) && person_picker_node is PersonPicker:
		person_picker_node.connect("item_selected", self, "select_from_index", [person_picker_node, Defaluts.PICKER_TYPES.PERSON])
		
	if is_instance_valid(font_picker_node) && font_picker_node is FontPicker:
		font_picker_node.connect("item_selected", self, "select_from_index", [font_picker_node, Defaluts.PICKER_TYPES.FONT])
		
	if is_instance_valid(mood_picker_node) && mood_picker_node is MoodPicker:
		mood_picker_node.connect("item_selected", self, "select_from_index", [mood_picker_node, Defaluts.PICKER_TYPES.MOOD])
		
	if is_instance_valid(align_picker_node) && align_picker_node is AlignPicker:
		align_picker_node.connect("item_selected", self, "select_from_index", [align_picker_node, Defaluts.PICKER_TYPES.ALIGN])

func get_base_dialog_index() -> int:
	return dialog_base_index

func _self_update():
	pass

func _gather_block_info() -> Dictionary:
	return {}
	
func _match_info_on_update(_key : String, data):
	pass

func update_block_from_info(info : Dictionary):
	for key in info.keys():
		_match_info_on_update(key, info[key])

func bound_to_node(node : String):
	if DialogData.is_node_in_dialog(ProjectManager.get_edit_dialog(), node):
		for msg in msgs:
			LangluageData.rename_message_key(form_locale_msg(msg), form_locale_msg(msg, node))
			
		dialog_node_name = node
		update_from_global()

func bound_to_key(key : String):
	if DialogData.is_key_in_node(ProjectManager.get_edit_dialog(), dialog_node_key, key):
		for msg in msgs:
			LangluageData.rename_message_key(form_locale_msg(msg), form_locale_msg(msg, "", key))
			
		dialog_node_key = key
		update_from_global()

func on_node_rename(_dialog : String, old_node_name : String, new_node_name : String):
	if old_node_name == dialog_node_name:
		bound_to_node(new_node_name)

func register_locale_key(key : String):
	if !key in msgs:
		msgs.append(key)
		LangluageData.add_message(form_locale_msg(key))
		emit_signal("msg_registred", form_locale_msg(key))

func unregister_locale_key(key : String):
	if key in msgs:
		msgs.erase(key)
		LangluageData.erase_message(form_locale_msg(key))
		emit_signal("msg_unregistred", form_locale_msg(key))

func form_locale_msg(key : String, node_name = "", node_key = "") -> String:
	if node_name != "" && node_key != "":
		return ProjectManager.get_edit_dialog() + "_" + node_name + "_" + node_key + "_" + key
	elif node_name != "":
		return ProjectManager.get_edit_dialog() + "_" + node_name + "_" + dialog_node_key + "_" + key
	elif node_key != "":
		return ProjectManager.get_edit_dialog() + "_" + dialog_node_name + "_" + node_key + "_" + key
		
	return ProjectManager.get_edit_dialog() + "_" + dialog_node_name + "_" + dialog_node_key + "_" + key
	
func update_from_global():
	update_block_from_info(DialogData.get_key_in_node(ProjectManager.get_edit_dialog(), dialog_node_name, dialog_node_key))
	_self_update()

func set_global():
	DialogData.set_key_in_node(ProjectManager.get_edit_dialog(), dialog_node_name, dialog_node_key, _gather_block_info())

func get_picked_person_id() -> String:
	return person_id
	
func get_picked_mood() -> int:
	return mood_id
	
func get_picked_font_name() -> String:
	return font_name

func get_picked_font() -> DynamicFont:
	if FontsData.is_font_in_list(font_name):
		return FontsData.get_font(font_name)	
	elif PersonsData.is_person_in_list(person_id):
		return PersonsData.get_person_font(person_id, ProjectManager.get_edit_lang())
	
	return FontsData.get_font(LangluageData.get_locale_font(ProjectManager.get_edit_lang()))

func get_picked_align() -> String:
	return align

func select_from_index(index : int, picker : OptionButton, picker_id : int):
	if !is_instance_valid(picker): return
	
	if index < 0: index = 0
		
	if picker.get_item_count() > index:
		match picker_id:
			Defaluts.PICKER_TYPES.PERSON:
				person_id = picker.get_item_text(index)
				emit_signal("person_picked")
				set_global()
				_self_update()
			Defaluts.PICKER_TYPES.MOOD:
				mood_id = index
				emit_signal("mood_picked")
				set_global()
				_self_update()
			Defaluts.PICKER_TYPES.FONT:
				font_name = picker.get_item_text(index)
				emit_signal("font_picked")
				set_global()
				_self_update()
			Defaluts.PICKER_TYPES.ALIGN:
				align = index
				emit_signal("align_picked")
				set_global()
				_self_update()

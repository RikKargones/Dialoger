extends Node

class_name TranslationController

export (NodePath) var path_to_node
export (NodePath) var path_to_translator
export (NodePath) var msg_holder

var msg_to_track = ""

signal text_updated
signal msg_seted

func _ready():
	ProjectManager.connect("edit_lang_changed", self, "on_msg_rename")
	
	if is_instance_valid(get_node_or_null(path_to_node)):
		var text_control 	= get_node(path_to_node)
		var translate_popup = get_node_or_null(path_to_translator)
		var graph_node		= get_node_or_null(msg_holder)
		
		bound_to_text_node(text_control)
		
		if is_instance_valid(translate_popup) && translate_popup is TranslateShower:
			translate_popup.set_track_control(text_control)
			connect("msg_seted", translate_popup, "set_translate_msg")
			text_control.connect("mouse_entered", translate_popup, "show_animated")
			text_control.connect("mouse_exited", translate_popup, "hide_animated")
			
		if is_instance_valid(graph_node) && graph_node is BasicGraphBlock:
			graph_node.connect("msg_registred", self, "set_msg_to_track")

func on_msg_rename(old_msg : String, new_msg : String):
	if old_msg == msg_to_track: set_msg_to_track(new_msg)

func is_node_textable(node : Control):
	return is_instance_valid(node) && (node is LineEdit || node is TextEdit || node is Label || node is RichTextLabel)

func bound_to_text_node(text_node : Control):
	if is_node_textable(text_node) && !is_connected("text_updated", text_node, "set_text"):
		connect("text_updated", text_node, "set_text")
		
	if (text_node is LineEdit || text_node is TextEdit) && !text_node.is_connected("text_changed", self, "on_text_change"):
		text_node.connect("text_changed", self, "on_text_change", [text_node])
	
	update_by_msg()

func set_msg_to_track(new_msg : String):
	msg_to_track = new_msg
	emit_signal("msg_seted", new_msg)
	update_by_msg()
	
func update_by_msg():
	emit_signal("text_updated", LangluageData.get_message(ProjectManager.get_edit_lang(), msg_to_track))

func on_text_change(text_edit : Control):
	if !is_instance_valid(text_edit): return

	if text_edit is TextEdit:
		var old_text = LangluageData.get_message(ProjectManager.get_edit_lang(), msg_to_track)
		
		if Defaluts.is_text_can_be_replic(text_edit.text):
			LangluageData.set_message(ProjectManager.get_edit_lang(), msg_to_track, text_edit.text)
		else:
			var old_pos_c = text_edit.cursor_get_column() - (text_edit.text.length() - old_text.length())
			var old_pos_l = text_edit.cursor_get_line()
			
			text_edit.text = old_text
			
			text_edit.cursor_set_line(old_pos_l)
			text_edit.cursor_set_column(old_pos_c)
	elif text_edit is LineEdit:
		LangluageData.set_message(ProjectManager.get_edit_lang(), msg_to_track, text_edit.text)

extends Control

class_name TranslateShower

onready var container 		= $PanelContainer
onready var compare_text 	= $PanelContainer/RichTextLabel

var track_control 	: Control
var tween 			: SceneTreeTween
var msg 			: String
var font_name		: String

func _ready():
	modulate.a = 0.0
	visible = false
	
	LangluageData.connect("msg_renamed", self, "on_msg_change")
	LangluageData.connect("msg_delited", self, "on_msg_delete")
	LangluageData.connect("msg_changed", self, "on_msg_update")
	
	ProjectManager.connect("compare_lang_changed", self, "update_text")

func set_track_control(control : Control):
	if is_instance_valid(track_control) && track_control.is_connected("item_rect_changed", self, "update_position"):
		track_control.disconnect("item_rect_changed", self, "update_position")
		
	track_control = control
	
	if is_instance_valid(track_control) && !track_control.is_connected("item_rect_changed", self, "update_position"):
		track_control.connect("item_rect_changed", self, "update_position")
	
	update_position()
	
func update_position():
	if !is_instance_valid(track_control):
		visible = false
		return
		
	var best_size = 0
	
	for line in compare_text.text.split("\n"):
		var string_size = compare_text.get_font("font").get_string_size(line).x
		if best_size < string_size:
			best_size = string_size

	container.rect_min_size.x = best_size + 50
	container.rect_min_size.y = track_control.rect_size.y + 10
	
	container.rect_global_position = track_control.rect_global_position
	container.rect_global_position.x += track_control.rect_size.x + 20
	container.rect_global_position.y -= 10

func update_text():
	if LangluageData.is_locale_in_list(ProjectManager.get_compare_lang()):
		compare_text.text = LangluageData.get_message(msg, ProjectManager.get_compare_lang())
	elif visible:
		hide_animated() 

func set_compare_font(new_font_name : String):
	font_name = new_font_name
	
	if compare_text.has_font_override("normal_font"): compare_text.remove_font_override("normal_font")
	compare_text.add_font_override("normal_font", FontsData.get_font(new_font_name))

func set_translate_msg(msg_id : String):
	msg = msg_id

func show_animated():
	if !is_instance_valid(track_control) || !LangluageData.is_locale_in_list(ProjectManager.get_compare_lang()): return
	
	if is_instance_valid(tween): tween.kill()
	
	update_position()
	
	if is_inside_tree() && !visible:
		tween = get_tree().create_tween()
		tween.tween_property(self, "visible", true, 0.1)
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
		tween.play()
	
func hide_animated():
	if is_instance_valid(tween): tween.kill()
	
	update_position()
	
	if is_inside_tree() && visible:
		tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		tween.chain().tween_property(self, "visible", false, 0.1)
		tween.play()

func on_msg_change(old_key : String, new_key : String):
	match old_key:
		msg: set_translate_msg(new_key)
	
func on_msg_delete(msg_key : String):
	match msg_key:
		msg: set_translate_msg("")
		
func on_msg_update(msg_key : String):
	match msg_key:
		msg: update_text()

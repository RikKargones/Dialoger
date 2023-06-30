extends GraphNode

class_name DialogBase

var dialog_type					= Global.DialogType.Replic
var dialog_load_priority		= 999
var dialog_get_func : FuncRef	= null
var current_lang				= Defaluts.get_main_lang_name()

var actions						= {}
var transalator_panels			= []
var translator_visible			= false
var lang_variants				= LangManager.new()
var snap 						= Vector2(1,1)
var mouse_inside 				= false

var minimaze_settings			= false
var hide_settings				= false

signal right_clicked
signal update_global
signal lost_slot
signal minimazed
signal set_as_start
signal translation_need

func parent_class_instansing():
	connect("resize_request", self, "resize")
	connect("close_request", self, "start_close")
	lang_variants.set_funcs(self, "set_lang_variant",  "get_lang_variant", "get_empty_lang_variant")
	
	remove_as_dialog_start()

func set_lang_variant(info):
	return
	
func get_lang_variant():
	return []
	
func get_empty_lang_variant():
	return []

func get_class():
	return Global.DialogType.keys()[dialog_type]

func set_dialog_getter(fnrf : FuncRef):
	dialog_get_func = fnrf

func get_current_dialog_info():
	if is_instance_valid(dialog_get_func) && dialog_get_func.is_valid():
		return dialog_get_func.call_func()
	return {}

func set_as_dialog_start():
	self_modulate = Color("328cff")
	emit_signal("set_as_start", self)
	remove_action("Set as dialog start")
	
func remove_as_dialog_start():
	self_modulate = Color.white
	add_action("Set as dialog start", funcref(self, "set_as_dialog_start"))

func _process(delta):
	if Rect2(Vector2(0,0), rect_size).has_point(get_local_mouse_position()):
		if Input.is_action_just_released("mouse_right_button"):
			emit_signal("right_clicked", self)
			

func on_ready():
	return

func update_text_variants():
	pass

func update_dependesy():
	pass

func check_map_popup_needness():
	return true
	
func get_translation_info(lang : String) -> Dictionary:
	return {}
	
func show_translation_info(yes : bool, lang_name = ""):
	translator_visible = yes
	
	update_panels(lang_name)

func add_translator_panel(to : Control):
	var hold = Control.new()
	var panel = PanelContainer.new()
	var label = Label.new()
	
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.set("custom_styles/panel", load("res://Other/PanelWithCornersWhite.tres"))
	panel.add_child(label, true)
	hold.add_child(panel, true)
	to.add_child(hold, true)
	to.move_child(hold, 0)
	hold.visible = translator_visible
	panel.rect_position = Vector2(-20, 0)
	transalator_panels.append(hold)
	
func update_panels(by : String):
	var info = get_translation_info(by)
	
	if info.size() > 0:
		var nods = info["Nodes"]
		var texts = info["Texts"]
		
		if abs(nods.size() - transalator_panels.size()) != 0:
			while nods.size() > transalator_panels.size():
				add_translator_panel(nods[nods.size() - (nods.size() - transalator_panels.size())])
			if nods.size() < transalator_panels.size():
				for panel in transalator_panels:
					var has = false
					for nod in nods:
						if panel in nod.get_children():
							has = true
							break
					if !has && is_instance_valid(panel):
						transalator_panels.erase(panel)
						panel.queue_free()
		
		for text_id in texts.size():
			transalator_panels[text_id].visible = translator_visible && texts[text_id].strip_edges() != "" && selected
			transalator_panels[text_id].get_child(0).get_child(0).text = texts[text_id]
		
func on_langlage_change(to_which):
	lang_variants.change_current_lang(to_which)
	update_on_lang_change()
	
func update_on_lang_change():
	pass

func on_rename_lang():
	return
	
func get_replic_info():
	return get_custom_replic_settings()

func get_custom_replic_settings() -> Dictionary:
	return {}

func set_settings_from_dict(data : Dictionary):
	set_custom_settings_from_dict(data)

func set_custom_settings_from_dict(data : Dictionary):
	pass

func set_settings_visibility(presset : int):
	match presset:
		0:
			minimaze_settings 	= false
			hide_settings		= false
		1:
			minimaze_settings	= true
			hide_settings		= false
		2:
			minimaze_settings	= false
			hide_settings		= true
			
	emit_signal("minimazed")
	on_minimaze()

func on_minimaze():
	pass

func update_snap(new_snap : int):
	snap = Vector2(new_snap, new_snap)
	rect_position = rect_position.snapped(snap)
	resize(rect_size)
	
func resize(new_size : Vector2):
	rect_size = new_size.snapped(snap)

func start_close():
	Global.confurm_something(funcref(self, "go_delete"), "Are you shure you want to delete this dialog part?")
	
func go_delete():
	lang_variants.queue_free()
	queue_free()

func get_actions_data():
	return actions

func add_action(action_name : String, action_func : FuncRef):
	actions[action_name] = action_func

func remove_action(action_name : String):
	if action_name in actions.keys():
		actions.erase(action_name)

func remove_slot(node):
	if !node.is_in_group("NOCHECK"):
		var count = 0
		
		for i in get_children():
			if i.is_in_group("NOCHECK"):
				count += 1
		
		emit_signal("lost_slot", name, node.get_position_in_parent() - count)

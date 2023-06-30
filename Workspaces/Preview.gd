extends MarginContainer

var def_vars 	= {}
var start_vars	= {}
var await_input = false
var clear_after_start = false

var dialog_processor : DialogProcessor

onready var consol_panel 		= $Output/AllOther/Consol
onready var simplised_debugger	= $Output/Line/OutputBt/SimplisedOutput
onready var debugger			= $Output/AllOther/Consol/MarginContainer/Panels/OutputInfo/Output
onready var clear_setting		= $Output/AllOther/Consol/MarginContainer/Panels/OutputInfo/ClearSet
onready var varible_list		= $Output/AllOther/Consol/MarginContainer/Panels/VaribleInfo/Scroll/List
onready var dialog_choser		= $Output/Line/DiaChoose
onready var option_list			= $Output/AllOther/DiaWindow/ChooseLine
onready var start_bt			= $Output/Line/StartBt
onready var end_bt				= $Output/Line/EndBt
onready var lang_changer		= $Output/Line/LangChangeBt
onready var dd_control			= $DD_CONTROL

onready var dialog_window		= $Output/AllOther
onready var dialog_text			= $Output/AllOther/DiaWindow/Dialog
onready var person_name_l		= $Output/AllOther/DiaWindow/Textures/Left/TextureRect/Label
onready var person_texture_l	= $Output/AllOther/DiaWindow/Textures/Left/TextureRect
onready var person_name_c		= $Output/AllOther/DiaWindow/Textures/Center/TextureRect/Label
onready var person_texture_c	= $Output/AllOther/DiaWindow/Textures/Center/TextureRect
onready var person_name_r		= $Output/AllOther/DiaWindow/Textures/Right/TextureRect/Label
onready var person_texture_r	= $Output/AllOther/DiaWindow/Textures/Right/TextureRect

onready var pck_varible 		= preload("res://Elements/VaribleSetter.tscn")

signal change_showed_current

func _ready():
	end_bt.disabled 		= true
	
	consol_panel.visible 	= false
	option_list.visible 	= false
	dialog_window.visible	= false
	clear_setting.pressed 	= clear_after_start
	
	reset_dialog_window()
	
	Global.connect("unblock_screen", self, "on_export_end")

func _physics_process(delta):
	if await_input && Input.is_action_just_released("ui_accept"):
		dialog_processor.process_next_part()
		await_input = false

func on_export_end():	
	var gd_script = ResourceLoader.load("user://Preview/Dialogs/DialogDispetcher.gd", "", true)
	
	if gd_script is GDScript:
		dd_control.set_script(null)
		yield(get_tree(), "idle_frame")
		dd_control.set_script(gd_script)
		if !dd_control.is_connected("dd_debug_message", self, "print_debug_msg"): dd_control.connect("dd_debug_message", self, "print_debug_msg")
		if !dd_control.is_connected("dd_started", self, "on_dialog_start"): dd_control.connect("dd_started", self, "on_dialog_start")
		if !dd_control.is_connected("dd_ended", self, "on_dialog_end"): dd_control.connect("dd_ended", self, "on_dialog_end")
		if !dd_control.is_connected("dd_varible_changed", self, "update_varible"): dd_control.connect("dd_varible_changed", self, "update_varible")
		_on_LangChangeBt_item_selected(lang_changer.selected)
	else:
		print("Error uccurs whlie loading exported script. Maybe it's an export issue.")

func reset_dialog_window():
	person_name_c.text = ""
	person_name_l.text = ""
	person_name_r.text = ""
	person_texture_c.texture = null
	person_texture_l.texture = null
	person_texture_r.texture = null

func on_dialog_start(_dia_name : String):
	if clear_after_start:
		debugger.text = ""
		simplised_debugger.text = ""
	emit_signal("change_showed_current", true)
	
func on_dialog_end(_dia_name : String):
	emit_signal("change_showed_current", false)
	dialog_text.text = ""
	start_bt.disabled 	= false
	end_bt.disabled 	= true
	reset_dialog_window()
	
func print_debug_msg(text : String):
	debugger.text += "\n" + text
	simplised_debugger.text += "\n" + text
	var messages = simplised_debugger.text.split(">", false)
	if messages.size() > 3:
		simplised_debugger.text = ""
		for num in 3:
			simplised_debugger.text = ">" + messages[messages.size() - 1 - num] + simplised_debugger.text

func set_mood(person, align, to_mood):
	match align:
		0:
			person_texture_l.set_meta("Person", person)
			person_texture_l.texture = to_mood
			person_texture_l.flip_h	= Defaluts.preview_miror_left
			
			if person_texture_c.get_meta("Person", "") == person:
				person_texture_c.texture = null
				person_texture_c.set_meta("Person", "")
			if person_texture_r.get_meta("Person", "") == person:
				person_texture_r.texture = null
				person_texture_r.set_meta("Person", "")
		1:
			person_texture_c.set_meta("Person", person)
			person_texture_c.texture = to_mood
			person_texture_c.flip_h	= Defaluts.preview_miror_center
			
			if person_texture_l.get_meta("Person", "") == person:
				person_texture_l.texture = null
				person_texture_l.set_meta("Person", "")
			if person_texture_r.get_meta("Person", "") == person:
				person_texture_r.texture = null
				person_texture_r.set_meta("Person", "")
		2:
			person_texture_r.set_meta("Person", person)
			person_texture_r.texture = to_mood
			person_texture_r.flip_h	= Defaluts.preview_miror_right
			
			if person_texture_c.get_meta("Person", "") == person:
				person_texture_c.texture = null
				person_texture_c.set_meta("Person", "")
			if person_texture_l.get_meta("Person", "") == person:
				person_texture_l.texture = null
				person_texture_l.set_meta("Person", "")
			
func show_text(person, font, align, text):
	var tween = get_tree().create_tween()
	
	dialog_text.set("custom_fonts/normal_font", font)
	
	match align:
		0:
			person_name_l.text = person
			person_name_l.self_modulate = Color.white
			person_name_c.self_modulate = Color.gray
			person_name_r.self_modulate = Color.gray
			if person_name_r.text == person: person_name_r.text = ""
			if person_name_c.text == person: person_name_c.text = ""
		1:
			person_name_c.text = person
			person_name_l.self_modulate = Color.gray
			person_name_c.self_modulate = Color.white
			person_name_r.self_modulate = Color.gray
			if person_name_r.text == person: person_name_r.text = ""
			if person_name_l.text == person: person_name_l.text = ""
		2:
			person_name_r.text = person
			person_name_l.self_modulate = Color.gray
			person_name_c.self_modulate = Color.gray
			person_name_r.self_modulate = Color.white
			if person_name_l.text == person: person_name_l.text = ""
			if person_name_c.text == person: person_name_c.text = ""
	
	dialog_text.percent_visible = 0
	dialog_text.text = text
	
	tween.tween_property(dialog_text,"percent_visible", 1.0, text.length() * 0.05)
	tween.play()
	
	yield(tween, "finished")
	
	if option_list.get_child_count() != 0:
		option_list.visible = true
	else:
		await_input = true

func set_options(options : Array):
	clear_option_list()
	for opt_id in options.size():
		var new_bt = Button.new()
		new_bt.text = options[opt_id][0]
		new_bt.disabled = !options[opt_id][1]
		option_list.add_child(new_bt)
		new_bt.connect("pressed", self, "on_option_choose", [opt_id], CONNECT_ONESHOT)

func clear_option_list():
	for child in option_list.get_children():
		child.queue_free()

func on_option_choose(opt_num):
	if is_instance_valid(dialog_processor):
		clear_option_list()
		option_list.visible = false
		dialog_processor.process_next_part(opt_num)

func update_dialogs():
	var old_name = dialog_choser.text
	dialog_choser.clear()
	
	if dd_control.dialog_names.keys().size() == 0:
		dialog_choser.add_item("<No dialogs>")
	else:
		for dia in dd_control.dialog_names.keys():
			dialog_choser.add_item(dia)
			if dia == old_name:
				dialog_choser.select(dialog_choser.get_item_count() - 1)

func set_to_defult():
	for node in varible_list.get_children():
		if node.get_varible_name() in def_vars.keys():
			node.set_varible(node.get_varible_name(), def_vars[node.get_varible_name()])
		else:
			queue_free()

func update_varible(var_name : String, value):
	for node in varible_list.get_children():
		if node.get_varible_name() == var_name:
			node.set_varible(node.get_varible_name(), value)
			break

func fill_list():
	var has_var = []
	
	for node in varible_list.get_children():
		if node.get_varible_name() in dd_control.varible_names.keys():
			has_var.append(node.get_varible_name())
			node.set_varible(node.get_varible_name(), dd_control.get_varible(dd_control.varible_names[node.get_varible_name()]))
		else:
			node.queue_free()
	
	for varible in dd_control.varible_names.keys():
		if !varible in has_var:
			var new_var = pck_varible.instance()
			varible_list.add_child(new_var)
			new_var.set_varible(varible, dd_control.get_varible(dd_control.varible_names[varible]))
			def_vars[varible] = dd_control.get_varible(dd_control.varible_names[varible])
			connect("change_showed_current", new_var, "set_current_vis")
			new_var.connect("var_changed", self, "update_dd_varible")

func update_dd_varible(var_name : String, value):
	dd_control.set_varible_by_name(var_name, value)

func _on_OutputBt_toggled(button_pressed):
	consol_panel.visible = button_pressed

func _on_DefVaribles_pressed():
	set_to_defult()

func _on_StartBt_pressed():
	if is_instance_valid(dialog_processor):
		dialog_processor.end()
	
	dialog_processor = dd_control.create_dialog(dialog_choser.text, true)
	dialog_processor.connect("dp_text_changed", self, "show_text")
	dialog_processor.connect("dp_options_presented", self, "set_options")
	dialog_processor.connect("dp_person_mood_changed", self, "set_mood")
	
	if is_instance_valid(dialog_processor):
		start_bt.disabled = true
		end_bt.disabled = false
		dialog_window.visible = true
		dialog_processor.start()

func _on_Preview_visibility_changed():
	if is_instance_valid(dialog_processor):
		dialog_processor.end()
	
	yield(get_tree(), "idle_frame")
	if !visible: return
	
	#For anti-falure export testing:
	if 1 != 1:
		ProjectManager.export_data(["user://Preview", true])
		on_export_end()
	elif Global.start_export("user://Preview", true) == OK:
		yield(Global, "unblock_screen")
		on_export_end()

func _on_DD_CONTROL_script_changed():
	if is_instance_valid(dd_control.get_script()):
		fill_list()
		update_dialogs()

func _on_EndBt_pressed():
	if is_instance_valid(dialog_processor):
		dialog_processor.end()

func _on_LangChangeBt_item_selected(index):
	while !is_instance_valid(dd_control): yield(get_tree(), "idle_frame")
	if is_instance_valid(dd_control.get_script()):
		while !is_instance_valid(lang_changer): yield(get_tree(), "idle_frame")
		dd_control.change_language(dd_control.get_lang_id_by_name(lang_changer.get_item_text(index)))

func _on_ClearSet_toggled(button_pressed):
	clear_after_start = button_pressed

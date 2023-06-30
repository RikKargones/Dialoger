extends Replick

onready var pck_option = preload("res://DialogEditorElements/DialogOption.tscn")

var translate_handler = null
var open_option_inst = null

func on_ready_extend():
	dialog_type = Global.DialogType.Options
	set_slot_enabled_right(0, false)

func set_lang_variant(info : Array):
	var idx = 0
	var option_names = info[1]
	
	words_node.text = info[0]
	
	for child in get_children():
		if child.is_in_group("DIAOPT"):
			if ProjectManager.is_font_in_atlas(lang_variants.get_font_from_lang()):
				child.set_option_font(ProjectManager.get_font_by_name(lang_variants.get_font_from_lang()))
				
			if idx < option_names.size():
				child.set_option_name(option_names[idx])
			else:
				child.set_option_name("")
				
			idx += 1
	
func get_lang_variant():
	var names = []
	
	for child in get_children():
		if child.is_in_group("DIAOPT"):
			names.append(child.get_option_name())
			
	return [words_node.text, names]
	
func get_empty_lang_variant():
	var names = ["", []]
	
	for child in get_children():
		if child.is_in_group("DIAOPT"):
			names[1].append("")
	
	return names

func get_custom_replic_settings() -> Dictionary:
	var data_dict = {}
	var options = []
	
	for child in get_children():
		if child.is_in_group("DIAOPT"):
			options.append(child.get_logic_info())
	
	data_dict["Person"] 	= name_changer.text
	data_dict["Align"] 		= align_chooser.selected
	data_dict["Mood"]		= mood_chooser.text
	data_dict["Words"]		= [font_chooser.text, lang_variants.get_all_variants(), options]
	
	return data_dict

func set_custom_settings_from_dict(data : Dictionary):
	for info_name in data.keys():
		var info = data[info_name]
		
		match info_name:
			"Person":
				for idx in name_changer.get_item_count():
					if info == name_changer.get_item_text(idx):
						name_changer.select(idx)
						break
				update_moods(name_changer.text)
			"Align":
				align_chooser.select(info)
			"Mood":
				for idx in mood_chooser.get_item_count():
					if info == mood_chooser.get_item_text(idx):
						mood_chooser.select(idx)
						break
			"Words":
				font_chooser.update_font_list()
				
				for item in font_chooser.get_item_count():
					if data["Words"][0] == font_chooser.get_item_text(item):
						font_chooser.select(item)
						break
				
				for item in data["Langs"][1]:
					var option = add_option()
					option.set_logic_info(item)
				
				yield(get_tree(), "idle_frame")
				
				lang_variants.set_all_variants(data["Words"][1])
		
	update_dependesy()

func add_option():
	var new_option = pck_option.instance()
	
	add_child(new_option)
	set_slot_enabled_right(get_child_count() - 1, true)
	new_option.connect("option_edit_opend", self, "on_option_logic_open")
	new_option.connect("option_edit_closed", self, "on_option_logic_closed")
	#new_option.connect("mouse_entered")
	
	return new_option

func on_minimaze():
	pass

func get_translation_info(lang : String) -> Dictionary:
	var variant = lang_variants.get_variant(lang)
	var options = [words_panel]
	
	for child in get_children():
		if child.is_in_group("DIAOPT"):
			options.append(child)
	
	return {"Nodes" : options, "Texts" : [variant[0]] + variant[1]}

func _on_Options_child_exiting_tree(node):
	remove_slot(node)
	
	if !is_queued_for_deletion():
		var num = 0
		
		for child in get_children():
			if child.is_in_group("DIAOPT"):
				if child == node:
					child.disconnect("option_edit_opend", self, "on_option_logic_open")
					child.disconnect("option_edit_closed", self, "on_option_logic_closed")
					if is_instance_valid(lang_variants):
						var texts = lang_variants.get_all_variants()
						for lang in texts.keys():
							if texts[lang][1].size() > num:
								texts[lang][1].remove(num)
						lang_variants.set_all_variants(texts)
					break
				num += 1
		
		yield(get_tree(), "idle_frame")
		rect_size = Vector2(0,0)

func _on_AddChoose_pressed():
	add_option()

func on_option_logic_open(option : DialogOption):
	if is_instance_valid(open_option_inst) && option != open_option_inst:
		open_option_inst.hide_logic_edit()
			
	open_option_inst = option
	
func on_option_logic_close(option : DialogOption):
	if is_instance_valid(open_option_inst) && open_option_inst == option:
		open_option_inst = null

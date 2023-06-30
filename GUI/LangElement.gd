extends MarginContainer

onready var lang_name 			= $Element/LangName
onready var lang_font_chooser 	= $Element/FontSet/FontChoose
onready var close_bt			= $Element/ContrlSet/DelBt

signal updated_name

func get_lang_name():
	return lang_name.text
	
func get_lang_font_name():
	return lang_font_chooser.text
	
func set_lang_name(new_name : String):
	
	lang_name.text = new_name

func block_deliting(yes = true):
	close_bt.disabled = yes

func set_lang_font(font_name : String):
	if font_name in ProjectManager.get_all_fonts().keys():
		for item in lang_font_chooser.get_item_count():
			if lang_font_chooser.get_item_text(item) == font_name:
				lang_font_chooser.select(item)

func finalise_rename(new_name : String):
	emit_signal("updated_name", lang_name.text, new_name)
	lang_name.text = new_name

func _on_RmBt_pressed():
	if is_instance_valid(get_parent()):
		var other_langs = []
		
		for child in get_parent().get_children():
			if child.has_method("get_lang_name") && child != self:
				other_langs.append(child.get_lang_name())
		
		Global.name_something(funcref(self, "finalise_rename"), "Введите уникальное название языка", other_langs)

func _on_DelBt_pressed():
	Global.confurm_something(funcref(self, "queue_free"), "Вы уверены?\nЭто сотрет всю локализацию во всем проекте.")

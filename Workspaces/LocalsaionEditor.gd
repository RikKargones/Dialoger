extends MarginContainer

onready var lang_list = $Full/List

var pck_lang_element = preload("res://GUI/LangElement.tscn")

func _ready():
	clear_data()
		
	ProjectManager.set_langs_collector(funcref(self, "update_global_atlas"))
	ProjectManager.connect("clear_project", self, "clear_data")
	SaveManager.lang_update_funcref = funcref(self, "set_all_langs")

func clear_data():
	var langs = ProjectManager.get_all_langs()
	
	for child in lang_list.get_children():
		child.queue_free()
	
	for lang in langs.keys():
		add_lang(lang, langs[lang])

func add_lang(lang_name : String, lang_font = ""):
	var new_lang = pck_lang_element.instance()
	
	lang_list.add_child(new_lang)
	new_lang.set_lang_name(lang_name)
	if lang_font != "": new_lang.set_lang_font(lang_font)
	
	new_lang.connect("updated_name", ProjectManager, "rename_lang")
	update_global_atlas()

func set_all_langs():
	for child in lang_list.get_children():
		child.queue_free()
	
	for lang in ProjectManager.font_lang_atlas.keys():
		add_lang(lang, ProjectManager.font_lang_atlas[lang])

func update_block_deliting():
	var counts_less = lang_list.get_child_count() < 2
	
	for child in lang_list.get_children():
		if child.has_method("block_deliting"):
			child.block_deliting(counts_less)

func update_global_atlas():
	var langs = {}
	
	for child in lang_list.get_children():
		if child.has_method("get_lang_name"):
			langs[child.get_lang_name()] = child.get_lang_font_name()
	
	ProjectManager.update_langs(langs)

func _on_LocalsaionEditor_visibility_changed():
	update_global_atlas()

func _on_AddBt_pressed():
	var langs = []
	
	for child in lang_list.get_children():
		if child.has_method("get_lang_name"):
			langs.append(child.get_lang_name())
	
	Global.name_something(funcref(self, "add_lang"), "Введите уникальное название языка", langs, true)

func _on_List_child_entered_tree(_node):
	yield(get_tree(), "idle_frame")
	update_block_deliting()

func _on_List_child_exiting_tree(_node):
	yield(get_tree(), "idle_frame")
	update_block_deliting()

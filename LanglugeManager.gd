extends Node

class_name LangManager

var loaded			= false
var current_lang 	= Defaluts.get_main_lang_name()
var variants 		= {}

var func_to_get 	: FuncRef
var func_to_set 	: FuncRef
var func_to_empty 	: FuncRef

func _init():
	for lang in ProjectManager.get_all_langs().keys():
		variants[lang] = []
	
	ProjectManager.connect("langs_updated", self, "on_lang_update")
	ProjectManager.connect("lang_renamed", self, "on_lang_rename")

func set_funcs(inst : Node, set_func : String, get_func : String, empty_func : String):
	func_to_set 	= funcref(inst, set_func)
	func_to_get 	= funcref(inst, get_func)
	func_to_empty 	= funcref(inst, empty_func)
	
	for lang in variants.keys():
		variants[lang] = call_empty()

func get_current_lang():
	return current_lang
	
func get_font_from_lang():
	if ProjectManager.is_lang_in_atlas(current_lang):
		return ProjectManager.get_all_langs()[current_lang]

func get_all_variants():
	save_info()
	return variants

func set_all_variants(new_variants : Dictionary):
	variants = new_variants
	call_set()
	loaded = true

func get_variant(lang_name):
	if lang_name in variants.keys():
		return variants[lang_name]
	
	return call_empty()

func change_current_lang(to):
	if to in variants.keys():
		save_info()
		current_lang = to
		call_set()

func call_set():
	if is_instance_valid(func_to_set) && func_to_set.is_valid():
		if current_lang in variants.keys():
			func_to_set.call_func(variants[current_lang])
		else:
			func_to_set.call_func(call_empty())

func call_empty():
	if is_instance_valid(func_to_empty) && func_to_empty.is_valid():
		return func_to_empty.call_func()
	return []

func call_get():
	if is_instance_valid(func_to_get) && func_to_get.is_valid():
		return func_to_get.call_func()
	return []

func save_info():
	variants[current_lang] = call_get()
	
func on_lang_update():
	for lang in ProjectManager.get_all_langs().keys():
		if !lang in variants.keys():
			variants[lang] = call_empty()
	
	for lang in variants.keys():
		if !ProjectManager.is_lang_in_atlas(lang):
			variants.erase(lang)
	
func on_lang_rename(old_name : String, new_name : String):
	if old_name in variants.keys():
		variants[new_name] = variants[old_name]
		variants.erase(old_name)
		if current_lang == old_name:
			call_set()

extends MarginContainer

onready var lang_list 		= $Full/Scroll/LangList
onready var lang_elem_pck 	= preload("res://GUI/LangElement.tscn")

var selection_count 		= 0

var elem_to_erase : LocaleElement

func _ready():
	LangluageData.connect("refresh_data", self, "set_from_data")
	
	for item in Defaluts.LocalesNames.keys():
		var new_item : LocaleElement = lang_elem_pck.instance()
		var long_name = Defaluts.LocalesNames[item]
		
		lang_list.add_child(new_item)
		
		new_item.set_locale_short(item)
		new_item.set_locale_name(long_name)
			
		new_item.connect("local_toggled", self, "selection_changed", [new_item])
		new_item.connect("font_changed", self, "selection_font_changed", [new_item])
		
	set_from_data()

func set_from_data():
	for item in lang_list.get_children():
		if item is LocaleElement:
			if item.get_locale_full() in LangluageData.get_locales_list():
				item.set_selection(true)
				item.set_locale_font(LangluageData.get_locale_font(item.get_locale_full()))
				selection_count += 1

func selection_changed(to : bool, element : LocaleElement):
	if !to && selection_count - 1 < 2: element.set_selection(true)
	
	if to:
		LangluageData.add_langluage(element.get_locale_short(), element.get_locale_font())
		selection_count += 1
	elif is_instance_valid(elem_to_erase):
		element.set_selection(true)
	else:
		Global.confurm_something(funcref(self, "remove_selection"), "Are you sure you want to remove this locale?\nAll translations will be erised.")
		element.set_selection(true)
		elem_to_erase = element

func selection_font_changed(new_font : String, element : LocaleElement):
	if !element.is_selected(): return
	
	LangluageData.set_langluage_font(element.get_locale_short(), new_font)

func remove_selection():
	if is_instance_valid(elem_to_erase):
		LangluageData.erase_langluage(elem_to_erase.get_locale_short())
		elem_to_erase.set_selection(false)
		selection_count -= 1

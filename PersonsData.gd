extends BaseData

#Maintence funcs
func ready_prepare():
	LangluageData.connect("refresh_data", self, "update_locales")

func set_key_by_defalut():
	for person in get_persons_list():
		erase_person(person)
	
	emit_signal("refresh_data")

func update_locales():
	for locale in LangluageData.get_locales_list():
		for person_id in get_persons_list():
			if get_person_name(person_id, locale) == "":
				set_person_name(person_id, locale, person_id)

func get_persons_list() -> Array:
	return data.keys()

func is_person_in_list(person_id : String) -> bool:
	return person_id in get_persons_list()

func set_filed(person_id : String, lang_name : String, filed : String, by : String):
	if !is_person_in_list(person_id): return
	
	LangluageData.set_message(get_as_data_filed(person_id, filed), lang_name, by)

func get_filed(person_id : String, lang_name : String, filed : String) -> String:
	if !is_person_in_list(person_id): return ""
	
	return LangluageData.get_message(get_as_data_filed(person_id, filed), lang_name)

func get_as_data_filed(key : String, filed : String) -> String:
	return "dia_person_" + key + "_" + filed

func copy_filed(from_key : String, to_key : String):
	if LangluageData.has_message(from_key):	LangluageData.rename_message_key(from_key, to_key)

#Interface func
func add_person(person_id : String, silent = false):
	data[person_id] = [Global.DialogePictureAligment.Left]
	
	for locale in LangluageData.get_locales_list():
		set_person_name(person_id, locale, person_id)
		set_person_font_name(person_id, locale, "")
	
func erase_person(person_id : String, silent = false):
	if !is_person_in_list(person_id): return
	
	LangluageData.erase_message(get_as_data_filed(person_id, "name"))
	LangluageData.erase_message(get_as_data_filed(person_id, "fontname"))
	
func get_person_align(person_id : String) -> int:
	if !is_person_in_list(person_id): return Global.DialogePictureAligment.Left
	return data[person_id][0]
	
func set_person_align(person_id : String, align : int):
	if !align in Global.DialogePictureAligment.values() || !is_person_in_list(person_id): return
	data[person_id][0] = align

func set_person_id(person_id : String, new_person_id : String):	
	if !is_person_in_list(person_id): return
	
	copy_filed(get_as_data_filed(person_id, "name"),  get_as_data_filed(new_person_id, "name"))
	copy_filed(get_as_data_filed(person_id, "fontname"),  get_as_data_filed(new_person_id, "fontname"))
	
	data[new_person_id] = data[person_id]
	data.erase(person_id)

func set_person_name(person_id : String, lang_name : String, new_name : String):
	set_filed(person_id, lang_name, "name", new_name)
	
func get_person_name(person_id : String, lang_name : String) -> String:
	return get_filed(person_id, lang_name, "name")

func set_person_font_name(person_id : String, lang_name : String, font_name : String):
	set_filed(person_id, lang_name, "fontname", font_name)
	
func get_person_font_name(person_id : String, lang_name : String) -> String:
	return get_filed(person_id, lang_name, "fontname")

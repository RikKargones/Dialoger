extends BaseData

var msg_list = []

signal locale_added
signal locale_font_changed
signal locale_removed
signal locales_updated

signal msg_added
signal msg_changed
signal msg_renamed
signal msg_delited

func set_key_by_defalut():
	data.clear()
	add_langluage(Defaluts.LocalesNames["en"], "")
	emit_signal("refresh_data")

func has_message(key : String):
	return key in msg_list

func get_msg_list() -> Array:
	return msg_list

func is_locale_short_valid(locale_short : String) -> bool:
	if !locale_short in Defaluts.LocalesNames.keys(): return false
	if get_locale_long(locale_short) == "": return false
	return true

func is_locale_in_list(locale_long : String):
	return locale_long in get_locales_list()

func get_locales_list() -> Array:
	return data.keys()
	
func get_locale_font(locale_long : String) -> String:
	if locale_long in get_locales_list(): return ""
	return data[locale_long][1]

func get_locale_long(locale_short : String) -> String:
	if Defaluts.LocalesNames[locale_short] in get_locales_list(): return ""
	else: return Defaluts.LocalesNames[locale_short]

func add_langluage(locale_short : String, font : String):
	if !is_locale_short_valid(locale_short): return
	
	var new_translation = Translation.new()
	var locale_long = get_locale_long(locale_short)
	
	new_translation.locale = locale_short
	
	for msg in msg_list: new_translation.add_message(msg, "")
	
	data[locale_long] = [new_translation, font]
	
	TranslationServer.add_translation(new_translation)
	
	FileManger.register_inside_resource(new_translation, "Translations")
	
	emit_signal("locale_added", locale_long)

func set_langluage_font(locale_short : String, new_font : String):
	if !is_locale_short_valid(locale_short): return
	
	data[get_locale_long(locale_short)][1] = new_font
	
	emit_signal("locale_font_changed", get_locale_long(locale_short))

func erase_langluage(locale_short : String):
	if !is_locale_short_valid(locale_short): return
	
	var locale_long = get_locale_long(locale_short)
	
	TranslationServer.remove_translation(data[locale_long])
	
	FileManger.unregister_inside_resource(data[locale_long].resource_name)
	
	data.erase(locale_long)
	
	emit_signal("locale_removed", locale_long)

func rename_message_key(old_key : String, new_key : String):
	if !has_message(old_key) || has_message(new_key): return
	
	for locale in get_locales_list():
		set_message(new_key, get_message(old_key, locale), locale)
	
	erase_message(old_key)
	
	emit_signal("msg_renamed", old_key, new_key)

func get_translation_element(locale_long : String) -> Translation:
	if !is_locale_in_list(locale_long): return null
	return data[locale_long][0]

func get_message(key : String, locale_long : String) -> String:
	if !is_locale_in_list(locale_long) || !has_message(key): return ""
	return get_translation_element(locale_long).get_message(key)

func add_message(key_msg : String):
	if has_message(key_msg): return
	
	msg_list.append(key_msg)
	
	for locale in data.keys():
		data[locale][0].add_message(key_msg, "")
	
	emit_signal("msg_added", key_msg)

func set_message(key_msg : String, msg : String, locale_long : String):
	if !has_message(key_msg): return
	
	if !is_locale_in_list(locale_long):
		Global.popup_error("Error! Trying to save msg into unexisted/unaded locale!")
		return
	
	var translation : Translation = data[locale_long][0]
	
	translation.erase_message(key_msg)
	translation.add_message(key_msg, msg)
	emit_signal("msg_changed", key_msg, locale_long)
	
func erase_message(key : String):
	if !has_message(key): return
	
	msg_list.erase(key)
	
	for locale in data.keys():
		data[locale][0].erase_message(key)
		
	emit_signal("msg_delited")

func _set_data_from_save(saved_data : Dictionary):
	msg_list = saved_data["MSG_LIST"]
	
	for key in saved_data.keys():
		if key != "MSG_LIST":
			var translation : Translation = FileManger.get_inside_resource(saved_data[key][0])
			if is_instance_valid(translation):
				TranslationServer.add_translation(translation)
				data[key] = [translation, saved_data[key][1]]

func _get_save_data() -> Dictionary:
	var saved_data = {"MSG_LIST" : msg_list}
	
	for locale in get_locales_list():
		var translation : Translation = data[locale][0]
		
		saved_data[locale] = [translation.resource_name, data[locale][1]]
	
	return saved_data

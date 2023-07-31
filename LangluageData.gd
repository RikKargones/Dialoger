extends BaseData

var msg_list = []

func set_key_by_defalut():
	data.clear()
	add_langluage(Defaluts.LocalesNames["en"], "")
	emit_signal("refresh_data")

func has_message(key : String):
	return key in msg_list

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
	
	emit_signal("refresh_data")

func set_langluage_font(locale_short : String, new_font : String):
	if !is_locale_short_valid(locale_short): return
	
	data[get_locale_long(locale_short)][1] = new_font
	
	emit_signal("refresh_data")

func erase_langluage(locale_short : String):
	if !is_locale_short_valid(locale_short): return
	
	var locale_long = get_locale_long(locale_short)
	
	TranslationServer.remove_translation(data[locale_long])
	
	data.erase(locale_long)
	
	emit_signal("refresh_data")

func rename_message_key(old_key : String, new_key : String):
	if !has_message(old_key) || has_message(new_key): return ERR_INVALID_PARAMETER
	
	for locale in get_locales_list():
		set_message(new_key, locale, get_message(old_key, locale))
	
	erase_message(old_key)

func get_translation_element(locale_long : String) -> Translation:
	if !is_locale_in_list(locale_long): return null
	return data[locale_long][0]

func get_message(key : String, locale_long : String) -> String:
	if !is_locale_in_list(locale_long) || !has_message(key): return ""
	return get_translation_element(locale_long).get_message(key)

func set_message(key_msg : String, locale_long : String, msg : String):
	if !is_locale_in_list(locale_long):
		Global.popup_error("Error! Trying to save msg into unexisted/unaded locale!")
		return
	
	var translation : Translation = data[locale_long][0]
	
	if has_message(key_msg):
		translation.erase_message(key_msg)
	else:
		msg_list.append(key_msg)
		
		for locale in data.keys():
			if locale != locale_long:
				data[locale][0].add_message(key_msg, "")
	
	translation.add_message(key_msg, msg)
	
func erase_message(key : String):
	if !has_message(key): return
	
	msg_list.erase(key)
	
	for locale in data.keys():
		data[locale][0].erase_message(key)

func set_data_from_save(save_data : Dictionary):
	msg_list = save_data["MSG_LIST"]
	
	for key in save_data.keys():
		if key != "MSG_LIST":
			add_langluage(save_data[key]["LOCALE"], save_data[key]["FONT"])
			
			for item_key in save_data[key].keys():
				var item_data = save_data[key][item_key]
				
				if item_key != "LOCALE" && item_key != "FONT":
					set_message(item_key, key, item_data)

func get_data_as_save() -> Dictionary:
	var save_data = {"MSG_LIST" : msg_list}
	
	for locale in get_locales_list():
		var translation : Translation = data[locale][0]
		
		save_data[locale] = {}
		save_data[locale]["FONT"] = data[locale][1]
		save_data[locale]["LOCALE"] = translation.locale
		
		for msg in msg_list: save_data[locale][msg] = translation.get_message(msg)
	
	return save_data

extends BaseData

signal person_added
signal person_id_changed
signal person_delited
signal person_name_changed
signal person_def_font_updated
signal person_def_align_updated

signal person_list_updated

signal person_mood_added
signal person_mood_renamed
signal person_mood_changed
signal person_mood_delited

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

func get_person_mood_id_list(person_id : String) -> Array:
	if is_person_in_list(person_id): return data[person_id]["Moods"].keys()
	else: return []
	
func get_person_mood_names_list(person_id : String) -> Array:
	var names = []
	
	if is_person_in_list(person_id):
		var count = 0
		
		while count in data[person_id]["Moods"].keys():
			names.append(data[person_id]["Moods"][count][0])
			count += 1
			
	return names

func is_mood_id_in_person(person_id : String, mood_id : int) -> bool:
	return is_person_in_list(person_id) && mood_id in get_person_mood_id_list(person_id)
	
func is_mood_in_person(person_id : String, mood_name : String) -> bool:
	if !is_person_in_list(person_id): return false
	
	for id in get_person_mood_id_list(person_id):
		if mood_name == get_person_mood_name(person_id, id):
			return true
	
	return false

func set_filed(person_id : String, lang_name : String, filed : String, by : String):
	if !is_person_in_list(person_id): return
	
	LangluageData.set_message(get_as_data_filed(person_id, filed), lang_name, by)

func get_filed(person_id : String, lang_name : String, filed : String) -> String:
	if !is_person_in_list(person_id): return ""
	
	return LangluageData.get_message(get_as_data_filed(person_id, filed), lang_name)

func get_as_data_filed(key : String, filed : String) -> String:
	return "dia_person_" + key + "_" + filed

func move_filed(from_key : String, to_key : String):
	if LangluageData.has_message(from_key):	LangluageData.rename_message_key(from_key, to_key)

func get_person_mood_name(person_id : String, mood_id : int) -> String:
	if is_mood_id_in_person(person_id, mood_id): return data[person_id]["Moods"][mood_id][0]
	return ""
	
func get_person_mood_texture(person_id : String, mood_id : int) -> Texture:
	if is_mood_id_in_person(person_id, mood_id): return data[person_id]["Moods"][mood_id][1]
	return null
	
func get_person_mood_filename(person_id : String, mood_id : int) -> String:
	if is_mood_id_in_person(person_id, mood_id): return data[person_id]["Moods"][mood_id][2]
	return ""
	
func set_mood_texture_from_path(person_id : String, mood_id : int, path : String, mood_name = ""):
	if !is_mood_id_in_person(person_id, mood_id): return
	
	var load_info 	= FileManger.register_external_file(path, "Res/" + person_id + "/Moods")
	var new_image 	= Image.new()
	var new_texture = ImageTexture.new()
	
	if load_info.size() > 1 && new_image.load(load_info[1] + "/" + load_info[0]) == OK:
		new_texture.create_from_image(new_image)
		if mood_name == "":
			mood_name = path.rsplit("/", false, 1)[1].rsplit(".", false, 1)[0]
		data[person_id]["Moods"][mood_id] = [mood_name, new_texture, load_info[0]]

#Interface func
func add_person(person_id : String):
	data[person_id] = {"Align" : Global.DialogePictureAligment.Left, "Moods" : {0 : ["<None>", null, ""]}}
	
	for locale in LangluageData.get_locales_list():
		set_person_name(person_id, locale, person_id)
		set_person_font_name(person_id, locale, "")
		
	emit_signal("person_added", person_id)

func add_person_mood_tex(person_id : String, path : String, mood_name = ""):
	if !is_person_in_list(person_id): return
	
	var new_id = 1
	
	while new_id in get_person_mood_id_list(person_id):
		new_id += 1
	
	set_mood_texture_from_path(person_id, new_id, path, mood_name)
	
	emit_signal("person_mood_added", person_id, new_id)

func set_person_mood_tex(person_id : String, mood_id : int, path : String, mood_name = ""):
	if !is_mood_id_in_person(person_id, mood_id): return
	
	FileManger.unregister_external_file(get_person_mood_filename(person_id, mood_id))
	
	set_mood_texture_from_path(person_id, mood_id, path, mood_name)
	
	emit_signal("person_mood_changed", person_id, mood_id)

func change_person_mood_name(person_id : String, mood_id : int, new_mood_name : String):
	if !is_mood_id_in_person(person_id, mood_id): return
	
	data[person_id]["Moods"][mood_id][0] = new_mood_name
	
	emit_signal("person_mood_renamed", person_id, mood_id)

func erase_person_mood(person_id : String, mood_id : int):
	if !is_mood_id_in_person(person_id, mood_id): return
	
	FileManger.unregister_external_file(data[person_id]["Moods"][mood_id][2])
	
	data[person_id]["Moods"].erase(mood_id)
	
	emit_signal("person_mood_delited", person_id, mood_id)

func erase_person(person_id : String, silent = false):
	if !is_person_in_list(person_id): return
	
	LangluageData.erase_message(get_as_data_filed(person_id, "name"))
	LangluageData.erase_message(get_as_data_filed(person_id, "fontname"))
	
	emit_signal("person_delited")
	
func get_person_align(person_id : String) -> int:
	if !is_person_in_list(person_id): return Global.DialogePictureAligment.Left
	return data[person_id]["Align"]
	
func set_person_align(person_id : String, align : int):
	if !align in Global.DialogePictureAligment.values() || !is_person_in_list(person_id): return
	
	data[person_id]["Align"] = align
	
	emit_signal("person_def_align_updated", person_id)

func set_person_id(old_person_id : String, new_person_id : String):	
	if !is_person_in_list(old_person_id): return
	
	move_filed(get_as_data_filed(old_person_id, "name"),  get_as_data_filed(new_person_id, "name"))
	move_filed(get_as_data_filed(old_person_id, "fontname"),  get_as_data_filed(new_person_id, "fontname"))
	
	data[new_person_id] = data[old_person_id]
	data.erase(old_person_id)
	
	emit_signal("person_id_changed", old_person_id, new_person_id)

func set_person_name(person_id : String, lang_name : String, new_name : String):
	if !is_person_in_list(person_id) || !LangluageData.is_locale_in_list(lang_name): return
	
	set_filed(person_id, lang_name, "name", new_name)
	
	emit_signal("person_name_changed", person_id, lang_name)
	
func get_person_name(person_id : String, lang_name : String) -> String:
	return get_filed(person_id, lang_name, "name")

func set_person_font_name(person_id : String, lang_name : String, font_name : String):
	if !is_person_in_list(person_id): return
	
	set_filed(person_id, lang_name, "fontname", font_name)
	
	emit_signal("person_def_font_updated", person_id)
	
func get_person_font_name(person_id : String, lang_name : String) -> String:
	return get_filed(person_id, lang_name, "fontname")

func get_person_font(person_id : String, lang_name : String) -> DynamicFont:
	return FontsData.get_font(get_person_font_name(person_id, lang_name))

func set_data_from_save(saved_data : Dictionary):
	for person_id in saved_data.keys():
		data[person_id] = {"Align" : saved_data[person_id]["Align"], "Moods" : {}}
		
		for mood in saved_data[person_id]["Moods"].keys():
			var mood_file : String	= saved_data[person_id]["Moods"][mood]
			var mood_path : String	= FileManger.get_external_file_path(mood_file)
			var new_image 			= Image.new()
			var new_texture 		= ImageTexture.new()
			
			if mood_path != "" && new_image.load(mood_path.trim_suffix("/") + "/" + mood_file) == OK:
				new_texture.create_from_image(new_image)
				data[person_id]["Moods"][mood] = [new_texture, mood_file]
	
func get_save_data() -> Dictionary:
	var saved_data = {}
	
	for person_id in get_persons_list():
		saved_data[person_id] = {"Align" : data[person_id]["Align"], "Moods" : {}}
		
		for mood in get_person_mood_id_list(person_id):
			saved_data[person_id]["Moods"][mood] = get_person_mood_filename(person_id, mood)
		
	return saved_data

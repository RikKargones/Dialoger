extends BaseData

var system_defalut_font = ""
var user_defalut_font	= ""

func ready_prepare():
	add_font("res://GUI/Reef.otf", "Dialoger")

func set_key_by_defalut():
	for font_name in get_fonts_list():
		delete_font(font_name)
		
	emit_signal("refresh_data")

func get_fonts_list() -> Array:
	return data.keys()

func is_font_in_list(font_name : String) -> bool:
	return font_name in data.keys()

func get_system_defalut_font_name():
	if is_font_in_list(user_defalut_font): return user_defalut_font
	return system_defalut_font

func get_font_defalut():
	if is_font_in_list(user_defalut_font): return user_defalut_font
	return get_font(system_defalut_font)

func get_font(font_name : String) -> DynamicFont:
	if is_font_in_list(font_name): return data[font_name][1]
	return null

func set_user_defalut_font(font_name : String):
	if is_font_in_list(font_name) || font_name == "": user_defalut_font = font_name
	emit_signal("refresh_data")

func add_font(path : String, custom_name = ""):
	var file_name : String = path.rsplit("/", true, 1)[1]
	var font_info = FileManger.register_external_file(path, "Res/Fonts")
	
	print(file_name)
	
	if font_info.size() > 0:
		var font_name_w_ex = font_info[0]
		var font_data = load(font_info[1] + "/" + font_name_w_ex)
		
		if font_data is DynamicFontData:
			var font 		= DynamicFont.new()
			var suffux 		= 1
			var font_name : String 	= file_name.rsplit(".", true, 1)[0]
			
			if custom_name != "": font_name = custom_name
			
			font_name = font_name.trim_suffix("font")
			font_name = font_name.trim_suffix("_")
			font.font_data = font_data
			
			var full_name = font_name + "_font"
			
			if full_name == "_font": full_name = "Untitled_font"
			
			while full_name in get_fonts_list():
				full_name = font_name + " (" + str(suffux) + ")"
				suffux += 1
			
			if data.keys().size() == 0: system_defalut_font = full_name
			
			data[full_name] = [font_name_w_ex, font]
			FileManger.register_inside_resource(font, "DynamicFont")
			emit_signal("refresh_data")
		else:
			Global.popup_error("File doesn't have dynamic font data.\nPlease, choose ONLY dynamic fonts (.otf, .ttf).")
	else:
		Global.popup_error("Something wrong with font file path. File can't be registred as external resurce.")

func change_font_data(font_name : String, path : String):
	if !is_font_in_list(font_name): return
	
	var new_font_info = FileManger.register_external_file(path, "Res/Fonts")
	
	if new_font_info.size() > 0:
		var font_name_w_ex = new_font_info[0]
		var font_data = load(new_font_info[1] + "/" + font_name_w_ex)
		
		if font_data is DynamicFontData:
			data[font_name][1].font_data = font_data
			
			FileManger.unregister_external_file(data[font_name][0])
			
			data[font_name][0] = font_name_w_ex
			emit_signal("refresh_data")
		else:
			Global.popup_error("FONT: File doesn't have dynamic font data.\nPlease, choose ONLY dynamic fonts (.otf, .ttf).")
	else:
		Global.popup_error("FONT: Something wrong with font file path. File can't be registred as external resurce.")

func change_font_name(old_font_name : String, new_font_name : String):
	if !is_font_in_list(old_font_name) || is_font_in_list(new_font_name): return
	
	data[new_font_name] = data[old_font_name]
	data.erase(old_font_name)
	
	emit_signal("refresh_data")
	
func delete_font(font_name : String):
	if !is_font_in_list(font_name): return
	
	FileManger.unregister_external_file(data[font_name][0])
	FileManger.unregister_inside_resource(data[font_name][1].resource_name)
	
	data.erase(font_name)
	
	emit_signal("refresh_data")

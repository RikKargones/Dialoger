extends Node

var version = "0.9.0"

var max_lines 				= 4
var default_font_size 		= 16
var max_symbols_per_line	= 100
var main_lang 				= "English"
var defalut_project_folder	= "user://Projects"

var preview_miror_left 		= true
var preview_miror_right 	= true
var preview_miror_center	= false


func reset_defaluts():
	max_lines 				= 4
	default_font_size 		= 16
	max_symbols_per_line 	= 100
	
	main_lang 				= "English"
	
	preview_miror_center 	= true
	preview_miror_left 		= true
	preview_miror_right		= false

func get_main_lang_name():
	return main_lang
	
func set_main_lang_name(lang_name):
	if lang_name in ProjectManager.font_lang_atlas.keys():
		main_lang = lang_name

func is_text_can_be_replic(text : String):
	var lines_req = text.countn("\n") < max_lines || max_lines == 0
	
	var one_line_lengh_req = true
	
	if max_symbols_per_line != 0:
		for line in text.split("\n"):
			if line.length() > max_symbols_per_line:
				one_line_lengh_req = false
				break
	
	return lines_req && one_line_lengh_req

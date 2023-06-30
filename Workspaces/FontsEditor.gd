extends MarginContainer

var replace_load_mode 		= false
var replace_font_child_id 	= null
var replace_font_name		= ""

var temp_main_font_file		= ""

onready var font_list = $Full/List

onready var pck_font = preload("res://Elements/FontSettings.tscn")

func _ready():
	var new_register = FileManger.register_temp_file("res://GUI/Reef.otf", "Res/Fonts")
	
	if new_register.size() > 0:
		temp_main_font_file = new_register[0]
		
	update_global_atlas()
	ProjectManager.set_fonts_collector(funcref(self, "update_global_atlas"))
	ProjectManager.connect("clear_project", self, "clear_data")
	SaveManager.font_update_funcref = funcref(self, "set_fonts")

func clear_data():
	for node in font_list.get_children():
		node.queue_free()

func set_fonts():	
	for font in ProjectManager.fonts_atlas.keys():
		if font != "Dialoger_font":
			make_new_font(ProjectManager.fonts_atlas[font])
			
func get_fonts():
	var fonts = {}
	
	for i in font_list.get_children():
		fonts[i.name] = i.get_main_font()
		
	fonts["Dialoger_font"] = [$Full/AddBt.get_font("font"), temp_main_font_file]
	
	return fonts

func update_global_atlas():
	ProjectManager.update_fonts_atlas(get_fonts())

func show_file_dialog(replace = false):
	Global.open_file(funcref(self, "make_new_font"), ["*.otf ; Open Type Font", "*.ttf ; True Type Font"], "Выберете файл шрифта")
	replace_load_mode = replace

func _on_AddBt_pressed():
	show_file_dialog()

func has_simullar_name(name_to_find : String):
	for i in font_list.get_children():
		if name_to_find == i.name:
			return true
	return false

func start_rename_child(child_id : Control):
	var names = []
	
	for child in font_list.get_children():
		if child != child_id:
			names.append(child.name)
			
	Global.name_something(funcref(child_id, "rename"), "Укажите уникальное название!", names)

func change_childs_font_data(child_id : Control, old_font_name : String):
	replace_font_child_id 	= child_id
	replace_font_name		= old_font_name
	show_file_dialog(true)

func make_new_font(path : String):
	var file_name = path.rsplit("/", true, 1)[1]
	var new_font_file = FileManger.register_temp_file(path, "Res/Fonts")
	
	if new_font_file.size() > 0:
		var font_file = new_font_file[0]
		var fontdata = load(new_font_file[1] + "/" + font_file)
		
		if fontdata is DynamicFontData:
			var font = DynamicFont.new()
			
			font.font_data = fontdata
			
			if replace_load_mode:
				if is_instance_valid(replace_font_child_id):
					FileManger.unregister_temp_file(replace_font_name)
					replace_font_child_id.set_main_font(font, font_file)
					replace_font_child_id 	= null
					replace_font_name 		= ""
			else:
				var font_settings 	= pck_font.instance()
				var font_name		= file_name.rsplit("_font", true, 1)[0]
				var font_extenson	= ""
				var suffix			= 0
				var names 			= []
				
				if "." in file_name:
					font_name 		= file_name.rsplit(".",true,1)[0]
					font_extenson 	= file_name.rsplit(".",true,1)[1]
				
				font_list.add_child(font_settings)
				
				for child in font_list.get_children():
					names.append(child.name)
				
				if font_name + "_font" in names:
					suffix += 1
					while font_name + "_font_" + str(suffix) in names: suffix += 1
				
				if suffix > 0: font_settings.name = font_name + "_font_" + str(suffix)
				else: font_settings.name = font_name + "_font"
				
				font_settings.set_main_font(font, font_file)
				font_settings.connect("change_name", self, "start_rename_child")
				font_settings.connect("change_font_data", self, "change_childs_font_data")
		else:
			Global.popup_error("File doesn't have dynamic font data.\nPlease, choose ONLY dynamic fonts (.otf, .ttf).")
	
func _on_Fonts_visibility_changed():
	update_global_atlas()

extends OptionButton

class_name FontPicker

var def_placeholder 				= ""
var reset_placeholder				= "<By defalut>"

var def_font_name		= ""
var current_font_name 	= ""

func _ready():
	update_font_list()
	reset_def_placeholder()
	FontsData.connect("refresh_data", self, "update_font_list")

func reset_def_placeholder():
	set_def_placeholder(reset_placeholder)

func set_def_placeholder(new_placeholder : String, new_def_font_name = ""):
	def_placeholder = new_placeholder
	
	def_font_name = new_def_font_name
	
	update_font_list()

func select_by_text(font_name : String):
	for item_idx in get_item_count():
		if get_item_text(item_idx) == font_name:
			select(item_idx)
			break
	
	if FontsData.is_font_in_list(font_name): current_font_name = font_name
	else: current_font_name = def_font_name
	
	update_font_ovverride()

func update_font_ovverride():
	if has_font_override("font"): remove_font_override("font")
	
	add_font_override("font", FontsData.get_font(current_font_name))

func get_current_font() -> DynamicFont:
	return FontsData.get_font(current_font_name)

func update_font_list():
	var list = [def_placeholder]
	list.append_array(FontsData.get_fonts_list())
	
	Global.update_selector(self, list)
	
	update_font_ovverride()

func select_by_id(index):
	select_by_text(get_item_text(index))

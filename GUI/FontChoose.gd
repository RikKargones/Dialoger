extends OptionButton

var def_placeholder 				= ""
var reset_placeholder				= "<By defalut>"

var def_font 		: DynamicFont 	= null
var current_font 	: DynamicFont	= null

func _ready():
	update_font_list()
	set_def_placeholder()
	ProjectManager.connect("fonts_updated", self, "update_font_list")

func _physics_process(delta):
	var font_name = text
	
	if ProjectManager.is_font_in_atlas(font_name):
		current_font = ProjectManager.get_font_by_name(font_name)
	else:
		current_font = def_font
		
	set("custom_fonts/font", current_font)

func set_def_placeholder(new_placeholder : String = "", new_def_font : DynamicFont = null):
	if new_placeholder == "": def_placeholder = reset_placeholder
	else: def_placeholder = new_placeholder
	
	def_font = new_def_font
	
	update_font_list()

func get_current_font() -> DynamicFont:
	return current_font

func update_font_list():
	var list = [def_placeholder] + ProjectManager.get_all_fonts().keys()
	
	Global.update_selector(self, list)

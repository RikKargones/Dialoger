extends DialogBase

class_name DialogVarible

onready var varible_chooser		= $Settings/Varible/VaribleSelector
onready var varible_settings	= $Settings/TabContainer

onready var bool_set_rv		= $Settings/TabContainer/BoolSettings/Reverse
onready var bool_set_set	= $Settings/TabContainer/BoolSettings/SetSettings/Set
onready var bool_set_val	= $Settings/TabContainer/BoolSettings/SetSettings/SetBt

onready var int_set_min		= $Settings/TabContainer/IntSettings/PaM/Minus
onready var int_set_pls		= $Settings/TabContainer/IntSettings/PaM/Plus
onready var int_set_byPM	= $Settings/TabContainer/IntSettings/PaM/FixedFiled
onready var int_set_set		= $Settings/TabContainer/IntSettings/Set
onready var int_set_byS		= $Settings/TabContainer/IntSettings/SetFiled

onready var string_set		= $Settings/TabContainer/StringSettings

onready var signal_set		= $Settings/TabContainer/SignalSettings/Arguments

func _ready():
	parent_class_instansing()
	dialog_type = Global.DialogType.Varible
	ProjectManager.connect("varibles_updated", self, "update_settings")
	rect_size = Vector2(0,0)

func _on_VaribleSelector_item_selected(index):
	var var_name = varible_chooser.get_item_text(index)
	show_settings_from_varible(var_name)
	
func update_settings():
	var var_name = varible_chooser.get_item_text(varible_chooser.selected)
	show_settings_from_varible(var_name)

func get_custom_replic_settings() -> Dictionary:
	var data = {}
	
	data["Varible"] 		= varible_chooser.text
	data["BoolSettings"] 	= [bool_set_rv.pressed, bool_set_set.pressed, bool_set_val.pressed]
	data["IntSettings"]		= [int_set_min.pressed, int_set_pls.pressed, int_set_byPM.value, int_set_set.pressed, int_set_byS.value]
	data["StringSettings"]	= [string_set.text]
	data["SignalSettings"]	= [signal_set.text]
	
	return data

func set_custom_settings_from_dict(data : Dictionary):
	for info in data.keys():
		match info:
			"Varible":
				for item in varible_chooser.get_item_count():
					if varible_chooser.get_item_text(item) == data[info]:
						varible_chooser.select(item)
						break
					
				show_settings_from_varible(data[info])
			"BoolSettings":
				bool_set_rv.pressed		= data[info][0]
				bool_set_set.pressed	= data[info][1]
				bool_set_val.pressed	= data[info][2]
			"IntSettings":
				int_set_min.pressed		= data[info][0]
				int_set_pls.pressed		= data[info][1]
				int_set_byPM.value		= data[info][2]
				int_set_set.pressed		= data[info][3]
				int_set_byS.value		= data[info][4]
			"StringSettings":
				string_set.text			= data[info][0]
			"SignalSettings":
				signal_set.text			= data[info][0]

func show_settings_from_varible(var_name):
	var vars_atlas = ProjectManager.get_all_varibles()
	
	if var_name in vars_atlas.keys():
		match vars_atlas[var_name][0]:
			"Bool":
				varible_settings.current_tab = 1
			"Integer":
				varible_settings.current_tab = 2
			"String":
				varible_settings.current_tab = 3
			"Signal":
				varible_settings.current_tab = 4
			_:
				varible_settings.current_tab = 0
	else:
		varible_settings.current_tab = 0
		
	rect_size = Vector2(0,0)

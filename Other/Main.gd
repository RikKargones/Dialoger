extends Panel

onready var workspace_node 		= $All/Scroller/Workspace
onready var switch_buttons		= $All/SelectBts
onready var screen_blocker		= $Blocker

onready var profiles_bt 		= $All/SelectBts/ProfilesBt
onready var vars_bt				= $All/SelectBts/VariblesBt
onready var langs_bt			= $All/SelectBts/LangsBt
onready var fonts_bt			= $All/SelectBts/FontsBt
onready var preview_bt			= $All/SelectBts/PreviewBt
onready var dialog_bt			= $All/SelectBts/DiaEditBt
onready var project_name_bt		= $All/SelectBts/ProjectName

func _ready():
	screen_blocker.visible 		= false
	
	profiles_bt.disabled 		= true
	vars_bt.disabled 			= true
	langs_bt.disabled 			= true
	fonts_bt.disabled 			= true
	preview_bt.disabled 		= true
	dialog_bt.disabled			= true
	project_name_bt.disabled 	= true
	
	project_name_bt.text = ProjectManager.project_name
	Global.connect("block_screen", self, "activate_block")
	Global.connect("unblock_screen", self, "deactivate_block")
	SaveManager.connect("save_load_finished", self, "on_load_finish")

func on_load_finish():
	profiles_bt.disabled 		= false
	vars_bt.disabled 			= false
	langs_bt.disabled 			= false
	fonts_bt.disabled 			= false
	preview_bt.disabled 		= false
	dialog_bt.disabled			= false
	project_name_bt.disabled 	= false
	
	project_name_bt.text = ProjectManager.project_name
	set_tab(3)

func set_tab(id : int):
	workspace_node.current_tab = id

func activate_block():
	screen_blocker.visible = true

func deactivate_block():
	screen_blocker.visible = false

func _on_ProjectsBt_pressed():
	set_tab(0)

func _on_SettingsBt_pressed():
	set_tab(1)

func _on_PreviewBt_pressed():
	set_tab(2)

func _on_DiaEditBt_pressed():
	set_tab(3)

func _on_ProfilesBt_pressed():
	set_tab(4)
	
func _on_FontsBt_pressed():
	set_tab(5)

func _on_VariblesBt_pressed():
	set_tab(6)

func _on_LangsBt_pressed():
	set_tab(7)

func _on_AboutBt_pressed():
	set_tab(8)

func _on_DialogEditor_hide_interface(is_true):
	switch_buttons.visible = is_true

func _on_Main_tree_exiting():
	FileManger.clear_temp_folder()

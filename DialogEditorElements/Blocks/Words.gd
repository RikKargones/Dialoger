extends BasicGraphBlock

onready var name_node = $UI/Label
onready var text_node = $UI/Words
onready var translator

func _init():
	dialog_base_index = Defaluts.DIALOG_BLOCKS.REPLICK
	register_locale_key("Text")

func _self_update():
	var person_name = PersonsData.get_person_name(person_id, ProjectManager.get_edit_lang())
	var font = get_picked_font()
	
	while !is_instance_valid(text_node): yield(get_tree(), "idle_frame")
	while !is_instance_valid(name_node): yield(get_tree(), "idle_frame")
	
	name_node.text = person_name
	
	if name_node.has_font_override("font"): name_node.remove_font_override("font")
	if text_node.has_font_override("font"): text_node.remove_font_override("font")
	
	name_node.add_font_override("font", font)
	text_node.add_font_override("font", font)

func _match_info_on_update(key : String, data):
	match key:
		"PersonID":
			person_id = data
		"Font":
			font_name = data
	
func _gather_block_info() -> Dictionary:
	return {"PersonID" : person_id, "Font" : font_name}

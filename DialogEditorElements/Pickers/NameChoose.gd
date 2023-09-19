extends OptionButton

class_name PersonPicker

var name_placeholder = "<None>"

func _ready():
	PersonsData.connect("refresh_data", self, "update_names")
	PersonsData.connect("person_list_updated", self, "update_names")
	update_names()

func update_names():
	var names = PersonsData.get_persons_list()
	var list = [name_placeholder] + names
	Global.update_selector(self, list)
	update_font()

func update_font():
	if selected < 0: selected = 0
	
	if has_font_override("font"): remove_font_override("font")
	
	add_font_override("font", PersonsData.get_person_font(get_item_text(selected), ProjectManager.get_edit_lang()))

func select_by_text(person_id : String):
	for idx in get_item_count():
		if person_id == get_item_text(idx):
			select(idx)
			update_font()
			break

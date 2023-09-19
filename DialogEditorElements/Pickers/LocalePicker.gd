extends OptionButton

class_name LocalePicker

func _ready():
	update_langs()
	LangluageData.connect("refresh_data", self, "update_langs")
	
func update_langs():
	Global.update_selector(self, LangluageData.get_locales_list())
	emit_signal("item_selected", selected)

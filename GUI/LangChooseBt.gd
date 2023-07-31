extends OptionButton

func _ready():
	update_langs()
	LangluageData.connect("refresh_data", self, "update_langs")
	
func update_langs(signaling = true):
	Global.update_selector(self, LangluageData.get_locales_list())
	if signaling: emit_signal("item_selected", selected)

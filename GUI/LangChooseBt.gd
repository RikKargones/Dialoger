extends OptionButton

func _ready():
	update_langs(true)
	ProjectManager.connect("langs_updated", self, "update_langs")
	ProjectManager.connect("lang_renamed", self, "rename_lang")
	
func update_langs(signaling = true):
	Global.update_selector(self, ProjectManager.get_all_langs().keys())
	if signaling: emit_signal("item_selected", selected)

func rename_lang(old_name : String, new_name : String):
	for item in get_item_count():
		if get_item_text(item) == old_name:
			if get_item_text(item) == text: text = new_name
			set_item_text(item, new_name)

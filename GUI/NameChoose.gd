extends OptionButton

var name_placeholder 	= "<None>"

func _ready():
	update_names()
	ProjectManager.connect("persons_updated", self, "update_names")

func update_names():
	var names = ProjectManager.get_all_persons().keys()
	var list = [name_placeholder] + names
	
	Global.update_selector(self, list)

func get_placeholder():
	return name_placeholder

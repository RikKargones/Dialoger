extends OptionButton

class_name AlignPicker

func _ready():
	Global.update_selector(self, Global.DialogePictureAligment.keys())
	

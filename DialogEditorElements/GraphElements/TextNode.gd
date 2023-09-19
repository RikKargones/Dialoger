extends BasicGraphNode

onready var person_picker 	= $Settings/PersonPicker
onready var font_picker 	= $Settings/FontPicker
onready var words			= $Words

func _ready():
	register_as_block(words, 1)

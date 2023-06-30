extends Button

onready var popup = $Popup

func _ready():
	popup.visible = false

func _pressed():
	popup.visible = !popup.visible

func _physics_process(delta):
	var center = popup.rect_size.x / 2 + rect_size.x / 2
	popup.rect_position = rect_global_position + rect_size
	
	if popup.rect_position.x - center + popup.rect_size.x > OS.window_size.x:
		popup.rect_position.x = OS.window_size.x - popup.rect_size.x
	else:
		popup.rect_position.x -= center

extends GraphNode

class_name DrogDropGraph

var actions		= {}
var snap 		= Vector2(1,1)
var mouse_inside = false

signal right_clicked

func _ready():
	connect("resize_request", self, "resize")
	connect("close_request", self, "start_close")

func _process(delta):
	if Input.is_action_just_released("mouse_right_button") && Rect2(Vector2(0,0), rect_size).has_point(get_local_mouse_position()):
		emit_signal("right_clicked", get_actions_data())

func show_description():
	$All.current_tab = 0
	
func show_node():
	$All.current_tab = 1
	
func show_icon():
	$All.current_tab = 2

func update_snap(new_snap : int):
	snap = Vector2(new_snap, new_snap)
	rect_position = rect_position.snapped(snap)
	resize(rect_size)
	
func resize(new_size : Vector2):
	rect_size = new_size.snapped(snap)

func start_close():
	Global.confurm_something(funcref(self, "go_delete"), "Вы точно хотите удалить эту часть диалога?")
	
func go_delete():
	queue_free()

func get_actions_data():
	return actions

extends Container

class_name ElementList

export (Vector2) 	var min_child_size 	setget min_child_size_updated
export (int)		var separation_h
export (int)		var separation_v

var scroll = VScrollBar.new()

func _ready():
	rect_clip_content = true
	call_deferred("add_child", scroll)
	scroll.connect("scrolling", self, "queue_sort")

func min_child_size_updated(new_size : Vector2):
	if new_size < Vector2(10,10): min_child_size = Vector2(10,10)
	else: min_child_size = new_size

func _on_ElementList_sort_children():
	var show_size_x = rect_size.x - scroll.rect_size.x
	var right_up = Vector2(get_rect().size.x, 0)
	var min_size = min_child_size
	var childs = get_children()
	
	for child in childs:
		if child is Control:
			if child == scroll:
				fit_child_in_rect(child, Rect2(right_up - Vector2(scroll.rect_size.x, -3), Vector2(scroll.rect_size.x, rect_size.y - 6)))
				childs.erase(scroll)
			else:
				min_size.x = max(min_size.x, child.rect_min_size.x)
				min_size.y = max(min_size.y, child.rect_min_size.y)
	
	var elem_per_line = int(max(floor(show_size_x / min_size.x), 1))
	var full_size = childs.size() / elem_per_line * min_size.y
	
	scroll.page = scroll.max_value / (full_size / rect_size.y)
	
	print(scroll.page)
	print(scroll.value)
	
	for index in childs.size():
		var position = Vector2()
		var index_x = index % elem_per_line
		var index_y = index / elem_per_line
		position.x = index_x * min_size.x
		position.y = index_y * min_size.y - scroll.value * scroll.page
		fit_child_in_rect(childs[index], Rect2(position, min_size))

extends MarginContainer

onready var new_popup 			= $Control/NewProjectPopup
onready var new_popup_name 		= $Control/NewProjectPopup/Margin/List/NameLine/NameEdit
onready var new_popup_path		= $Control/NewProjectPopup/Margin/List/PathLine/PathFiled

onready var save_list 			= $Recent/ScrollContainer/MarginContainer/RecentList

var popup_path = ""

var save_item_pck = preload("res://GUI/SaveItem.tscn")


extends OptionButton

class_name MoodPicker

var same_name	= "<Same>"
var my_person	= ""

func _ready():
	PersonsData.connect("refresh_data", self, "set_my_person")

func set_my_person(person_id = ""):
	var moods = [same_name]
	
	if person_id != "": my_person = person_id
	
	moods.append_array(PersonsData.get_person_mood_names_list(my_person))
	
	Global.update_selector(self, moods)
		
func get_selected_mood() -> String:
	if selected < 0: return ""
	return get_item_text(selected)
		
func is_selected_same():
	return selected > 0 && PersonsData.is_mood_id_in_person(my_person, selected)
	
func is_selected_empty():
	return selected == 0

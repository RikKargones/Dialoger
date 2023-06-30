extends MarginContainer

onready var export_status 	= $All/PrefAndStatus/Status
onready var progress_bar	= $All/ProgressBar

func set_percent(percent : float):
	progress_bar.value = percent

func progress_percent(step_percent : float):
	#print(step_percent)
	progress_bar.value += step_percent
	#print(progress_bar.value)

func set_status(status_text : String):
	export_status.text = status_text
	#print(status_text)

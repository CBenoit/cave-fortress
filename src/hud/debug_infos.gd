extends Control

var fps_label
var hp_label

func _ready():
	fps_label = get_node("vbox/fps")


	set_process(!is_hidden())
	set_process_input(true)

func _input(event):
	if event.is_action("display_debug") && event.is_pressed():
		set_hidden(!is_hidden())
		set_process(!is_hidden())

func _process(delta):
	fps_label.set_text("FPS: %d" % Performance.get_monitor(Performance.TIME_FPS))



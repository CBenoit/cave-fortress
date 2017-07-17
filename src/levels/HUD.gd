extends CanvasLayer

var debug_node
var current_weapon_label
var fps_label

func _ready():
	debug_node = get_node("debug")
	current_weapon_label = get_node("debug/vbox/current_weapon")
	fps_label = get_node("debug/vbox/fps")

	set_process(!debug_node.is_hidden())
	set_process_input(true)

func _input(event):
	if event.is_action("display_debug") && event.is_pressed():
		debug_node.set_hidden(!debug_node.is_hidden())
		set_process(!debug_node.is_hidden())

func _process(delta):
	fps_label.set_text("FPS: %d" % Performance.get_monitor(Performance.TIME_FPS))

func current_weapon_changed(new_weapon):
	current_weapon_label.set_text("Weapon name: %s" % new_weapon.name)

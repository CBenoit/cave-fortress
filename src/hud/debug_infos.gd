extends Control

var current_weapon_label
var fps_label
var hp_label

func _ready():
	current_weapon_label = get_node("vbox/current_weapon")
	fps_label = get_node("vbox/fps")
	hp_label = get_node("vbox/hp")

	set_process(!is_hidden())
	set_process_input(true)

func _input(event):
	if event.is_action("display_debug") && event.is_pressed():
		set_hidden(!is_hidden())
		set_process(!is_hidden())

func _process(delta):
	fps_label.set_text("FPS: %d" % Performance.get_monitor(Performance.TIME_FPS))

func current_weapon_changed(new_weapon):
	current_weapon_label.set_text("Weapon name: %s" % new_weapon.name)

func hp_changed(new_hp):
	hp_label.set_text("HP: %d" % new_hp.health)

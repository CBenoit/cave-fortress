extends CanvasLayer

var debug_infos
var health_bar
var wave_progress

func _ready():
	debug_infos = get_node("debug_infos")
	health_bar = get_node("health_bar")
	wave_progress = get_node("wave_progress")

func hp_changed(new_hp):
	health_bar.set_value(new_hp.health)

func wave_update(ratio):
	wave_progress.set_value(100*ratio)
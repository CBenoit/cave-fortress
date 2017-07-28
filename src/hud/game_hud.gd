extends CanvasLayer

onready var debug_infos = get_node("debug_infos")
onready var health_bar = get_node("health_bar")
onready var wave_progress = get_node("wave_progress")
onready var weapon_name = get_node("weapon_box/weapon_name")
onready var current_ammo = get_node("weapon_box/current_ammo")
onready var max_ammo = get_node("weapon_box/max_ammo")

func hp_changed(new_hp):
	health_bar.set_value(new_hp.health)

func wave_update(ratio):
	wave_progress.set_value(100*ratio)

func update_weapon_hud( name, ammo, maximum_ammo):
	weapon_name.set_text("%s" % name)
	if maximum_ammo != -1:
		current_ammo.set_text("%d \n    /" % ammo)
		max_ammo.set_text("       %d" % maximum_ammo)

	current_ammo.set_hidden(maximum_ammo == -1)
	max_ammo.set_hidden(maximum_ammo == -1)
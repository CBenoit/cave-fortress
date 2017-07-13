extends Sprite

const AUTOMATIC_MODE = 0
const SEMI_AUTO_MODE = 1

export(float, 0.01, 15, 0.01) var fire_interval_sec = 0.1
export(float, 0, 2, 0.01) var fire_angle = 0
export(PackedScene) var bullet_scn
export(int, "Automatic", "Semi-auto") var mode

var fire_sound
var fire_position

var timestamp_last_shot = 0

func _ready():
	fire_sound = get_node("fire_sound")
	fire_position = get_node("fire_position")

func fire():
	if timestamp_last_shot + fire_interval_sec * 1000 <= OS.get_ticks_msec():
		timestamp_last_shot = OS.get_ticks_msec()
		fire_sound.play("fire")
		_create_bullets()

func _create_bullets():
	# default behaviour: one bullet taking into account the given fire angle
	var bullet = bullet_scn.instance()
	bullet.orientation = get_rot() + rand_range(-fire_angle / 2, fire_angle / 2)
	bullet.set_pos(fire_position.get_global_pos())
	bullet.add_collision_exception_with(get_node("..")) # avoid collision with the shooter...
	get_node("../..").add_child(bullet) # add the bullets to the node "entities" in abstract_level

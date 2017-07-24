extends Sprite

enum {
	AUTOMATIC_MODE,
	SEMI_AUTO_MODE,
	HAS_INTENSITY
}

export(String) var name = "unknown"
export(float, 0.01, 15, 0.01) var fire_interval_sec = 0.1
export(float, 0, 2, 0.02) var fire_angle = 0
export(int,1,20,1) var bullet_num = 1
export(PackedScene) var bullet_scn
export(int, "Automatic", "Semi-auto", "Has intensity") var mode  = AUTOMATIC_MODE

var fire_sound
var fire_position
var solids_tilemap

var timestamp_last_shot = 0

func _ready():
	fire_sound = get_node("fire_sound")
	fire_position = get_node("fire_position")
	solids_tilemap = get_node("../../../solids")

func fire():
	if solids_tilemap.get_cellv(solids_tilemap.world_to_map(fire_position.get_global_pos())) != SolidTiles.TILE_EMPTY:
		return # do not shoot from inside walls…

	if timestamp_last_shot + fire_interval_sec * 1000 <= OS.get_ticks_msec():
		timestamp_last_shot = OS.get_ticks_msec()
		fire_sound.play("fire")
		_create_bullets()

func _create_bullets():
	# default behaviour: bullets taking into account the given fire angle
	var bullets = []
	for i in range(bullet_num):
		bullets.append(bullet_scn.instance())
		bullets[i].orientation = get_rot() + rand_range(-fire_angle / 2, fire_angle / 2)
		bullets[i].set_pos(fire_position.get_global_pos())
		bullets[i].team = get_node("..").team
		for j in range(i): # removing collisions with previously created bullets
			bullets[i].add_collision_exception_with(bullets[j])
		get_node("../..").add_child(bullets[i]) # add the bullets to the node "entities" in abstract_level

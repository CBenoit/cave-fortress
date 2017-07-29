extends Sprite

enum {
	AUTOMATIC_MODE,
	SEMI_AUTO_MODE
}

export(String) var name = "unknown"
export(float, 0.01, 15, 0.01) var fire_interval_sec = 0.1
export(float, 0, 2, 0.02) var fire_angle = 0.0
export(int,1,20,1) var bullet_num = 1
export(PackedScene) var bullet_scn
export(PackedScene) var spark_scn = preload("res://effects/gun_spark.tscn")
export(int, "Automatic", "Semi-auto") var mode  = AUTOMATIC_MODE
export(float, 0, 1, 0.01) var min_intensity = 1.0
export(float, 0, 1, 0.01) var max_intensity = 1.0
export(float, 0, 1, 0.01) var full_intensity_time = 0.0


onready var fire_sound = get_node("fire_sound")
onready var fire_position = get_node("fire_position")
onready var solids_tilemap = get_node("../../../solids")

var timestamp_last_shot = 0

signal shot(time_pressed)

func fire(time_pressed):
	if solids_tilemap.get_cellv(solids_tilemap.world_to_map(fire_position.get_global_pos())) != SolidTiles.TILE_EMPTY:
		return # do not shoot from inside walls…

	if timestamp_last_shot + fire_interval_sec * 1000 <= OS.get_ticks_msec():
		timestamp_last_shot = OS.get_ticks_msec()
		fire_sound.play("fire")
		emit_signal("shot",time_pressed)

		# create spark effect
		var spark = spark_scn.instance()
		get_node("../..").add_child(spark)
		spark.set_pos(fire_position.get_global_pos())
		spark.activate()

		# calculate intensity
		var intensity
		if time_pressed >= full_intensity_time:
			intensity = max_intensity
		else:
			intensity = min_intensity + (max_intensity - min_intensity) * time_pressed / full_intensity_time

		_create_bullets(intensity)

func _create_bullets(intensity):
	# default behaviour: bullets taking into account the given fire angle
	# doesn't take into account intensity
	var bullets = []
	for i in range(bullet_num):
		bullets.append(bullet_scn.instance())
		bullets[i].orientation = get_rot() + rand_range(-fire_angle / 2, fire_angle / 2)
		bullets[i].set_pos(fire_position.get_global_pos())
		bullets[i].team = get_node("..").team
		for j in range(i): # removing collisions with previously created bullets
			bullets[i].add_collision_exception_with(bullets[j])
		get_node("../..").add_child(bullets[i]) # add the bullets to the node "entities" in abstract_level

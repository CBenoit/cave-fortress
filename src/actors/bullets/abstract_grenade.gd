extends RigidBody2D

export(bool) var on_colliding = false
export(float,0,10,0.1) var timer = 5
export(int,1,200,1) var power = 30
export(float,0,320,1) var radius = 100
export(PackedScene) var explosion_effect_scn

var solids_tilemap
var sound_emitter
var previous_angle
var explosion_area

var already_exploded = false

func _ready():
	previous_angle = get_linear_velocity().angle()
	solids_tilemap = get_node("../../solids")
	sound_emitter = get_node("sound_emitter")

	explosion_area = get_node("explosion_area")
	get_node("explosion_area/shape").get_shape().set_radius(radius)

	set_fixed_process(true)

func _fixed_process(delta):
	timer -= delta

	if (timer < 0): # if the time is out, boom
		explode()
	elif bounced():
		sound_emitter.play("grenade_collide")
		if on_colliding: #if the grenade is to explode on hit.. and collides, boom
			explode()

	previous_angle = get_linear_velocity().angle()

func explode():
	if already_exploded: # to avoid infinite loop between grenades
		return

	already_exploded = true

	var center = get_pos()

	# damaging the tiles
	var tile_size = SolidTiles.TILE_SIZE
	var n = ceil(radius/tile_size) #maximum number of tiles in line reached by the explosion

	for x in range(center.x - n*tile_size, center.x + n*tile_size, tile_size):
		for y in range(center.y - n*tile_size, center.y + n*tile_size, tile_size):
			var vertex = Vector2(x, y)
			var l = (vertex - center).length()

			if (l < radius): # deals the damage if within the radius of the explosion
				# damages = power in the center and half of it at the rim, linear scaling
				solids_tilemap.damage_tile(solids_tilemap.world_to_map(vertex),power - (power/2)*(l/radius))

	# damaging entities
	for entity in explosion_area.get_overlapping_bodies():
		var distance = (entity.get_pos() - center).length()
		for grp in entity.get_groups():
			if grp == "damageable":
				entity.hp.take_damage(power - (power/2)*(distance/radius))
			elif grp == "grenade":
				entity.explode()
			elif grp == "pushable":
				entity.push(Vector2(cos(get_pos().angle_to_point(entity.get_pos()) + PI / 2) * power * 100 / distance, -power * 100 / distance))

	# spawn the explosion effect
	var effect = explosion_effect_scn.instance()
	effect.set_pos(get_pos())
	effect.set_scale(Vector2(radius / 7, radius / 7))
	get_node("../").add_child(effect)
	effect.activate()

	queue_free()

func bounced():
	if abs(get_linear_velocity().y) < 20 and abs(get_linear_velocity().x) < 20:
		return false # no need to continue

	var current_angle = get_linear_velocity().angle()
	if rad2deg(abs(current_angle - previous_angle)) < 5:
		return false

	return true

extends RigidBody2D

export(bool) var on_colliding = false
export(float,0,10,0.1) var timer = 5
export(int,1,200,1) var power = 30
export(float,32,320,1) var radius = 100

var solids_tilemap

func _ready():
	solids_tilemap = get_node("../../solids")

	set_contact_monitor(true)
	set_max_contacts_reported(1)
	set_fixed_process(true)


func _fixed_process(delta):
	timer -= delta

	if ( timer < 0):#if the time is out, boom
		explode()
		queue_free()
	elif get_colliding_bodies().size() != 0 and on_colliding: #if the grenade is to explode on hit.. and collides, boom
		explode()
		queue_free()

func explode():
	var center = get_pos()
	var tile_size = TilemapsConstants.TILE_SIZE
	var n = ceil(radius/tile_size) #maximum number of tiles in line reached by the explosion

	for x in range(center.x - n*tile_size, center.x + n*tile_size, tile_size):
		for y in range(center.y - n*tile_size, center.y + n*tile_size, tile_size):
			var vertex = Vector2(x,y)
			var l = (vertex - center).length()

			if ( l < radius): # deals the damage if within the radius of the explosion
				# damages = power in the center and half of it at the rim, linear scaling
				solids_tilemap.damage_tile(solids_tilemap.world_to_map(vertex),power - (power/2)*(l/radius))
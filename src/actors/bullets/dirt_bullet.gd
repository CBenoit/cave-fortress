extends "./abstract_bullet.gd"

func _on_colliding():
	var collider = get_collider()
	if "solids" in collider.get_groups():
		collider.set_cellv(collider.world_to_map(get_pos()), SolidTiles.TILE_DIRT) # TODO: allow tile selection?

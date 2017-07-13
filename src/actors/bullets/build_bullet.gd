extends "./abstract_bullet.gd"

func _on_colliding(remaining_motion):
	var collider = get_collider()
	if "solids" in collider.get_groups():
		collider.set_cellv(collider.world_to_map(get_pos()), SolidTiles.TILE_STEEL) # TODO: allow tile selection?

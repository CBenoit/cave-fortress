extends "./abstract_bullet.gd"

func _on_colliding():
	# apply damages to collider if applicable
	var collider = get_collider()
	if "solids" in collider.get_groups():
		var collision_pos = get_pos()
		if collider.get_cellv(collider.world_to_map(collision_pos)) == SolidTiles.TILE_EMPTY:
			collision_pos += Vector2(cos(orientation), -sin(orientation)) * TilemapsConstants.TILE_SIZE / 8
		collider.damage_tile(collider.world_to_map(collision_pos), power)

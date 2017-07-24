extends "./abstract_bullet.gd"

func _on_colliding():
	# apply damages to collider if applicable
	var collider = get_collider()
	for grp in collider.get_groups():
		if grp == "solids":
			var collision_pos = get_pos()
			if collider.get_cellv(collider.world_to_map(collision_pos)) == SolidTiles.TILE_EMPTY:
				collision_pos += Vector2(cos(orientation), -sin(orientation)) * SolidTiles.TILE_SIZE / 4
			collider.damage_tile(collider.world_to_map(collision_pos), power)
		elif grp == "grenade":
			collider.apply_impulse(Vector2(0, 0), Vector2(cos(orientation) * speed * power, -sin(orientation) * speed * power))
		elif grp == "damageable":
			if team == collider.team:
				add_collision_exception_with(collider)
				return false # cancel the collision
			else:
				collider.hp.take_damage(power)

	return true

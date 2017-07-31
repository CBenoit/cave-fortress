extends "./abstract_bullet.gd"

func _on_colliding():
	# apply damages to collider if applicable
	var collider = get_collider()
	for grp in collider.get_groups():
		if grp == "solids":
			var collision_pos = get_pos()
			if collider.get_cellv(collider.world_to_map(collision_pos)) == SolidTiles.TILE_EMPTY:
				collision_pos += Vector2(cos(orientation), -sin(orientation)) * SolidTiles.TILE_SIZE / 4
			collider.damage_tile(collider.world_to_map(collision_pos), power / 2.5)
		elif grp == "grenade":
			collider.explode()
		elif grp == "damageable":
			if team == collider.team:
				add_collision_exception_with(collider)
				return false # cancel the collision
			elif collider.hp.health > 0: # shotgun has shown problematic for dealt_damage calculation
				emit_signal("hit",hp_removed(collider, power))
				collider.hp.take_damage(power)


	return true

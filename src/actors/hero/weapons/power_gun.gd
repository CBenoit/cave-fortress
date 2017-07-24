extends "./abstract_grenade_weapon.gd"

func _create_bullets():
	var grenade = bullet_scn.instance()
	grenade.set_pos(fire_position.get_global_pos())

	grenade.get_node("Sprite").set_scale(5*intensity*Vector2(1,1))
	var collision_shape = grenade.get_node("CollisionShape2D")
	collision_shape.get_shape().set_radius(5*intensity*10) # 10 was picked by trials
	grenade.power = grenade.power*intensity*10
	grenade.radius = grenade.radius*intensity*10

	var theta = get_rot()
	var axis = Vector2(cos(theta),-sin(theta))
	grenade.set_axis_velocity(axis*velocity*intensity)
	grenade.add_collision_exception_with(get_node(".."))

	get_node("../..").add_child(grenade)


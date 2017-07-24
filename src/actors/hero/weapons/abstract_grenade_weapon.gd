extends "./abstract_weapon.gd"

export(float,0,1000,1) var velocity = 300

var intensity = 1 # ratio of the maximum speed the grenade will be fired/launched(used for handgrenades)

func _create_bullets():
	var grenade = bullet_scn.instance()
	grenade.set_pos(fire_position.get_global_pos())

	var theta = get_rot()
	var axis = Vector2(cos(theta),-sin(theta))
	grenade.set_axis_velocity(axis*velocity*intensity)
	grenade.add_collision_exception_with(get_node(".."))

	get_node("../..").add_child(grenade)

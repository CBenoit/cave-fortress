extends "./abstract_weapon.gd"

var strike_area
export(float,0,100,1) var strike_damage = 10

func _ready():
	strike_area = get_node("strike_area")

func _create_bullets():
	var wielder_team = get_node("..").team
	for entity in strike_area.get_overlapping_bodies():
		var grps = entity.get_groups()
		if "damageable" in grps:
			if entity.team != wielder_team:
				entity.hp.take_damage(strike_damage)
			if "pushable" in grps:
				push(entity)

func push(object):
	var pos = get_pos()
	if pos.x < strike_area.get_pos().x:
		pos += Vector2(15,0)
	else:
		pos -= Vector2(15,0)
	object.move(pos)

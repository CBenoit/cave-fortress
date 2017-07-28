extends "./pickable_item.gd"

export(int,0,100,1) var weapon_id
export(int,1,100,1) var quantity

func _ready():
	item_info.set_text("%s \n%d" %[Weapons.id_to_name[weapon_id], quantity])

func _pick(collider):
	if collider.ammunition[weapon_id][collider.AMMO] < collider.ammunition[weapon_id][collider.MAX_AMMO]:
		collider.add_ammunition(weapon_id, quantity)
		to_free = true

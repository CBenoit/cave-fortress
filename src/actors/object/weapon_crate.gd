extends "./pickable_item.gd"

export(int,0,100,1) var weapon_id

func _ready():
	item_info.set_text("%s" %Weapons.id_to_name[weapon_id])


func _pick(collider):

	if collider.carried_weapons.size() < Weapons.MAX_CARRIED:
		collider.add_weapon(weapon_id)
		to_free = true
	else: # should be displayed in an announcement label of the HUD
		print("You are carrying too many weapons")

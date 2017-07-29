extends "./pickable_item.gd"

export(int,0,100,1) var weapon_id

func _ready():
	item_info.set_text("%s" %Weapons.id_to_name[weapon_id])


func _pick(collider):

	if collider.carried_weapons.size() < Weapons.MAX_CARRIED and not collider.has_weapon(weapon_id):
		collider.add_weapon(weapon_id)

		get_node("../").add_child(sound_effect)
		sound_effect.picked_sound.play("weapon_pick")
		queue_free()
	else: # should be displayed in an announcement label of the HUD
		print("You are carrying too many weapons")

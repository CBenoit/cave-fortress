extends "./pickable_item.gd"

export(int,1,100,1) var quantity = 25


func _pick(collider):
	if collider.hp.health < collider.hp.max_health:
		collider.hp.restore_hp(quantity)

		get_node("../").add_child(sound_effect)
		sound_effect.picked_sound.play("food")

		queue_free()
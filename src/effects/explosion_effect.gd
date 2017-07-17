extends "./abstract_effect.gd"

func _on_activate():
	get_node("remaining_smoke").set_emitting(true)
	get_node("projected_smoke").set_emitting(true)
	get_node("fire").set_emitting(true)

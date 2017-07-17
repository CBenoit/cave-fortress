extends "./abstract_effect.gd"

func _on_activate():
	get_node("projections").set_emitting(true)

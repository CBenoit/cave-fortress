extends "abstract_effect.gd"

func _on_activate():
	get_node("quick_projection").set_emitting(true)
	get_node("going_up_blocks").set_emitting(true)

func set_color(color):
	get_node("quick_projection").set_color(color)
	get_node("going_up_blocks").set_color(color)

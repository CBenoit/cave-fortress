extends KinematicBody2D

export(float, -4, 4) var orientation = 0
export(int, 1, 1500) var speed = 1000
export(int, 0, 50) var power = 1
export(float, 0, 30, 0.01) var lifetime_sec = 10
export(PackedScene) var impact_effect_scn

var time_alive = 0
var team = Team.UNKNOWN

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# move the bullet
	advance(speed * delta)

	if is_colliding():
		if _on_colliding():
			# spawn impact effect
			var effect = impact_effect_scn.instance()
			effect.set_pos(get_pos())
			get_node("../").add_child(effect)
			effect.activate()

			queue_free() # this free the bullet safely

	time_alive += delta
	if time_alive > lifetime_sec:
		queue_free()

func _on_colliding():
	return true

func advance(force):
	var direction = Vector2(cos(orientation), -sin(orientation))
	move(direction * force)

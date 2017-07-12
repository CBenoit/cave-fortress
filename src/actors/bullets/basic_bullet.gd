extends KinematicBody2D

export var orientation = 0.0
export var speed = 1000

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	var direction = Vector2(cos(orientation), -sin(orientation))
	move(direction * speed * delta)

	if is_colliding():
		queue_free()

extends KinematicBody2D

export var orientation = 0.0
export var speed = 1000
export var power = 1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# move the bullet
	advance(speed * delta)

	if is_colliding():
		_on_colliding()
		queue_free() # this free the bullet safely

func _on_colliding():
	pass

func advance(force):
	var direction = Vector2(cos(orientation), -sin(orientation))
	move(direction * force)


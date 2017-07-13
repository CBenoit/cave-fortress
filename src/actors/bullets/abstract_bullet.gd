extends KinematicBody2D

export var orientation = 0.0
export var speed = 1000
export var power = 1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# move the bullet
	var direction = Vector2(cos(orientation), -sin(orientation))
	var remaining_motion = move(direction * speed * delta)

	if is_colliding():
		_on_colliding(remaining_motion)
		queue_free() # this free the bullet safely

func _on_colliding(remaining_motion):
	pass

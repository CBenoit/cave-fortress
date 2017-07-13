extends KinematicBody2D

export var orientation = 0.0
export var speed = 1000
export var power = 1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# move the bullet
	var direction = Vector2(cos(orientation), -sin(orientation))
	move(direction * speed * delta)

	if is_colliding():
		# apply damages to collider if applicable
		var collider = get_collider()
		if "solid" in collider.get_groups():
			collider.damage(power)

		queue_free() # this free the bullet safely


extends KinematicBody2D

const JUMP_MAX_AIRBORNE_TIME = 0.1
const JUMP_INFLUENCE_START_TIME = 0.05
const JUMP_INFLUENCE_MAX_TIME = 0.15

export var walk_speed = 128
export var gravity = 313.6
export var jump_power = 150

signal killed()

var basic_bullet_scn = preload("res://actors/bullets/basic_bullet.tscn")
var build_bullet_scn = preload("res://actors/bullets/build_bullet.tscn")

var body_sprite
var arm_sprite
var shoot_position
var camera
var camera_anim

var velocity = Vector2()
var on_air_time = 0
var jumping = false
var jump_time = 0 # relative to airbone time
var x_jump_velocity = 0
var killed = false
var focused = false

func _ready():
	body_sprite = get_node("body")
	arm_sprite = get_node("arm")
	shoot_position = get_node("arm/shoot_position")
	camera = get_node("camera")
	camera_anim = get_node("camera/camera_anim")

	set_fixed_process(true)
	set_process_input(true)
	set_process(true)

func _input(event):
	if event.is_action_released("attack"):
		var bullet = build_bullet_scn.instance()
		bullet.orientation = arm_sprite.get_rot()
		bullet.set_pos(shoot_position.get_global_pos())
		get_node("..").add_child(bullet)

func _process(delta):
	_update_arm_rotation()

func _update_arm_rotation():
	var mouse_vec = get_local_mouse_pos().normalized()
	arm_sprite.set_rot(Vector2(-mouse_vec.y, mouse_vec.x).angle())
	if arm_sprite.get_rot() > PI / 2 or arm_sprite.get_rot() < -PI / 2:
		arm_sprite.set_flip_v(true)
		arm_sprite.set_draw_behind_parent(true)
		body_sprite.set_flip_h(true)

		if arm_sprite.get_rot() < 5 * PI / 7 and arm_sprite.get_rot() > 0:
			arm_sprite.set_rot(5 * PI / 7)
		elif arm_sprite.get_rot() > -5 * PI / 7 and arm_sprite.get_rot() < 0:
			arm_sprite.set_rot(-5 * PI / 7)
	else:
		arm_sprite.set_flip_v(false)
		arm_sprite.set_draw_behind_parent(false)
		body_sprite.set_flip_h(false)

		if arm_sprite.get_rot() > 2 * PI / 7:
			arm_sprite.set_rot(2 * PI / 7)
		elif arm_sprite.get_rot() < -2 * PI / 7:
			arm_sprite.set_rot(-2 * PI / 7)

func kill():
	if(!killed):
		killed = true
		body_sprite.set_modulate(Color(1, 0, 0))
		camera_anim.play("shaking")
		set_fixed_process(false)
		emit_signal("killed")

func _fixed_process(delta):
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")

	if jumping: # air control
		if walk_left:
			velocity.x = x_jump_velocity - walk_speed / 2
			#x_jump_velocity = (velocity.x + x_jump_velocity) / 2
		elif walk_right:
			velocity.x = x_jump_velocity + walk_speed / 2
			#x_jump_velocity = (velocity.x + x_jump_velocity) / 2
		else:
			velocity.x = x_jump_velocity
	else:
		if walk_left:
			velocity.x = -walk_speed
		elif walk_right:
			velocity.x = walk_speed
		else:
			velocity.x = 0

	velocity.y += gravity * delta

	# integrate velocity to motion
	var motion = velocity * delta

	# move and consume motion
	motion = move(motion)

	var floor_velocity = Vector2()
	if(is_colliding()):
		var n = get_collision_normal()

		if (rad2deg(acos(n.dot(Vector2(0, -1)))) == 0):
			# If angle to the "up" vectors is null, then: on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
			jumping = false

		x_jump_velocity = 0
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

	# move with floor
	move(floor_velocity * delta)

	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not jumping:
		velocity.y = -jump_power
		jumping = true
		x_jump_velocity = velocity.x
		jump_time = on_air_time
	elif on_air_time > jump_time + JUMP_INFLUENCE_START_TIME and on_air_time < jump_time + JUMP_INFLUENCE_MAX_TIME and jump and jumping:
		velocity.y -= jump_power * delta * 5

	on_air_time += delta

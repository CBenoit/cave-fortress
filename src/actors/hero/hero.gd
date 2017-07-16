extends KinematicBody2D

const JUMP_MAX_AIRBORNE_TIME = 0.1
const JUMP_INFLUENCE_START_TIME = 0.05
const JUMP_INFLUENCE_MAX_TIME = 0.15
const MIN_JUMP_SPEED_HEAD_DAMAGE = 140

export var walk_speed = 128
export var gravity = 313.6
export var jump_power = 150

signal killed()

var basic_weapon_scn = preload("res://actors/hero/weapons/basic_weapon.tscn")
#TODO: var build_weapon_scn = preload("res://actors/hero/weapons/build_weapon.tscn")

var body_sprite
var arm_right_position
var arm_left_position
var weapon
var camera
var camera_anim
var sound_voice
var weapons = [
	preload("res://actors/hero/weapons/basic_weapon.tscn"),
	preload("res://actors/hero/weapons/shotgun.tscn"),
	preload("res://actors/hero/weapons/build_gun.tscn")
]
var picked_weapon = 0

var velocity = Vector2()
var on_air_time = 0
var jumping = false
var jump_time = 0 # relative to airbone time
var x_jump_velocity = 0
var killed = false
var focused = false

func _ready():
	body_sprite = get_node("body")
	arm_right_position = get_node("body/arm_right")
	arm_left_position = get_node("body/arm_left")
	weapon = get_node("weapon")
	camera = get_node("camera")
	camera_anim = get_node("camera/camera_anim")
	sound_voice = get_node("voice")

	set_fixed_process(true)
	set_process_input(true)
	set_process(true)

func _input(event):
	if weapon.mode == weapon.SEMI_AUTO_MODE:
		if event.is_action_released("attack"):
			weapon.fire()
	# weapon switching
	if event.is_action_pressed("next_weapon"):
		picked_weapon = (picked_weapon + 1) % weapons.size()

		weapon.queue_free()
		weapon = weapons[picked_weapon].instance()
		add_child(weapon)
	if event.is_action_pressed("previous_weapon"):
		picked_weapon = (picked_weapon - 1) % weapons.size()

		weapon.queue_free()
		weapon = weapons[picked_weapon].instance()
		add_child(weapon)

func _process(delta):
	_update_arm_rotation()

func _update_arm_rotation():
	var mouse_vec = get_local_mouse_pos().normalized()
	weapon.set_rot(Vector2(-mouse_vec.y, mouse_vec.x).angle())
	if weapon.get_rot() > PI / 2 or weapon.get_rot() < -PI / 2:
		weapon.set_flip_v(true)
		body_sprite.set_flip_h(true)
		weapon.set_pos(arm_left_position.get_pos())
	else:
		weapon.set_flip_v(false)
		body_sprite.set_flip_h(false)
		weapon.set_pos(arm_right_position.get_pos())

func kill():
	if(!killed):
		killed = true
		body_sprite.set_modulate(Color(1, 0, 0))
		camera_anim.play("shaking")
		set_fixed_process(false)
		emit_signal("killed")

func _fixed_process(delta):
	if weapon.mode == weapon.AUTOMATIC_MODE:
		if Input.is_action_pressed("attack"):
			weapon.fire()

	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")

	if jumping: # air control
		if walk_left:
			velocity.x = x_jump_velocity - walk_speed / 2
		elif walk_right:
			velocity.x = x_jump_velocity + walk_speed / 2
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

		if (n.x == 0 and n.y < 0):
			# If the normal strictly goes "up", then: on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
			jumping = false
		elif jumping and n.y > 0 and velocity.y < -MIN_JUMP_SPEED_HEAD_DAMAGE:
			var pick = round(rand_range(0.5,11.5))
			if not sound_voice.is_voice_active(0):
				sound_voice.play("cri" + str(pick))

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

extends KinematicBody2D

const JUMP_MAX_AIRBORNE_TIME = 0.1
const JUMP_INFLUENCE_START_TIME = 0.05
const JUMP_INFLUENCE_MAX_TIME = 0.15
const MIN_JUMP_SPEED_HEAD_DAMAGE = 140
const MIN_VELOCITY_FALL_DAMAGE = 400

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

export var movement_speed = 128
export var gravity = 313.6
export var jump_power = 150
export(int, "Unknown", "Ally", "Enemy") var team

# nodes
var hp

# movements attributes
var velocity = Vector2()
var on_air_time = 0
var jumping = false
var jump_time = 0 # relative to airbone time
var x_jump_velocity = 0
var pushed = false

# wanted movements
var go_left = false
var go_right = false
var jump = false

signal take_head_damage()
signal take_fall_damage()

func set_go_left(value):
	go_left = value

func set_go_right(value):
	go_right = value

func set_jump(value):
	jump = value

func _ready():
	hp = get_node("hp")
	hp.connect("killed", self, "_die")

	set_fixed_process(true)

func _fixed_process(delta):
	_pre_fixed_process(delta)

	if jumping: # air control
		if go_left:
			velocity.x = x_jump_velocity - movement_speed / 2
		elif go_right:
			velocity.x = x_jump_velocity + movement_speed / 2
		else:
			velocity.x = x_jump_velocity
	elif on_air_time < JUMP_MAX_AIRBORNE_TIME and not pushed:
		if go_left:
			velocity.x = -movement_speed
		elif go_right:
			velocity.x = movement_speed
		else:
			velocity.x = 0

	velocity.y += gravity * delta

	# integrate velocity to motion
	var motion = velocity * delta

	# move and consume motion
	motion = move(motion)

	if(is_colliding()):
		var n = get_collision_normal()

		if (n.x == 0 and n.y < 0):
			# If the normal strictly goes "up", then: on floor
			if velocity.y > MIN_VELOCITY_FALL_DAMAGE:
				_take_fall_damage()
			on_air_time = 0
			jumping = false
			pushed = false
		elif jumping and n.y > 0 and velocity.y < -MIN_JUMP_SPEED_HEAD_DAMAGE:
			_take_head_damage()

		if on_air_time == 0 \
				and get_travel().length() < SLIDE_STOP_MIN_TRAVEL \
				and abs(velocity.x) < SLIDE_STOP_VELOCITY:
			revert_motion()
			velocity.y = 0.0
		else:
			x_jump_velocity = 0
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)

	if on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not jumping:
		velocity.y = -jump_power
		jumping = true
		x_jump_velocity = velocity.x
		jump_time = on_air_time
	elif on_air_time > jump_time + JUMP_INFLUENCE_START_TIME and on_air_time < jump_time + JUMP_INFLUENCE_MAX_TIME and jump and jumping:
		velocity.y -= jump_power * delta * 5

	on_air_time += delta

	_post_fixed_process(delta)

func _pre_fixed_process(delta):
	pass

func _post_fixed_process(delta):
	pass

func _die():
	pass

func _take_head_damage():
	pass

func _take_fall_damage():
	pass

func push(direction):
	pushed = true
	velocity.x = direction.x
	velocity.y = direction.y
	x_jump_velocity = velocity.x
	move(Vector2(0, -5))
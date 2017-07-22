extends "../creature.gd"

signal weapon_changed(new_weapon)

# nodes attributes
var body_sprite
var arm_right_position
var arm_left_position
var weapon
var camera
var camera_anim
var sound_voice

# weapons attributes
var picked_weapon = 0
var weapons_scn = [
	preload("res://actors/hero/weapons/basic_weapon.tscn"),
	preload("res://actors/hero/weapons/shotgun.tscn"),
	preload("res://actors/hero/weapons/grenade_launcher.tscn"),
	preload("res://actors/hero/weapons/build_gun.tscn")
]

# build attributes
var builder_arm_scn = preload("construction/builder_arm.tscn")
var build_mode = false

# other
var killed = false

func _ready():
	body_sprite = get_node("body")
	arm_right_position = get_node("body/arm_right")
	arm_left_position = get_node("body/arm_left")
	weapon = get_node("weapon")
	camera = get_node("camera")
	camera_anim = get_node("camera/camera_anim")
	sound_voice = get_node("voice")

	set_process_input(true)
	set_process(true)

	connect("take_head_damage", self, "handle_head_damage")
	connect("take_fall_damage", self, "handle_fall_damage")

func _input(event):
	if event.is_action_pressed("mode_change"):
		switch_build_mode()

	if build_mode:
		if event.is_action_pressed("attack"):
			weapon.create_block()
		elif event.is_action_pressed("next_weapon"):
			weapon.change_picked_tile(1)
		elif event.is_action_pressed("previous_weapon"):
			weapon.change_picked_tile(-1)
	else:
		if weapon.mode == weapon.SEMI_AUTO_MODE:
			if event.is_action_released("attack"):
				weapon.fire()

		# weapon switching
		if event.is_action_pressed("next_weapon"):
			picked_weapon = (picked_weapon + 1) % weapons_scn.size()
			change_weapon_by_weapon_idx(picked_weapon)
		elif event.is_action_pressed("previous_weapon"):
			picked_weapon = (picked_weapon - 1) % weapons_scn.size()
			change_weapon_by_weapon_idx(picked_weapon)

func _process(delta):
	_update_arm_rotation()

func _update_arm_rotation():
	var mouse_vec = get_local_mouse_pos()
	weapon.set_rot(Vector2(-mouse_vec.y, mouse_vec.x).angle())

	if weapon.get_rot() > PI / 2 or weapon.get_rot() < -PI / 2:
		weapon.set_flip_v(true)
		body_sprite.set_flip_h(true)
		weapon.set_pos(arm_left_position.get_pos())
	else:
		weapon.set_flip_v(false)
		body_sprite.set_flip_h(false)
		weapon.set_pos(arm_right_position.get_pos())

func _die():
	body_sprite.set_modulate(Color(1, 0, 0))
	camera_anim.play("shaking")

func _pre_fixed_process(delta):
	if build_mode:
		if Input.is_action_pressed("secondary_action"):
			weapon.remove_block()
	else:
		if weapon.mode == weapon.AUTOMATIC_MODE:
			if Input.is_action_pressed("attack"):
				weapon.fire()

	set_go_left(Input.is_action_pressed("move_left"))
	set_go_right(Input.is_action_pressed("move_right"))
	set_jump(Input.is_action_pressed("jump"))

func change_weapon_by_weapon_idx(weapon_idx):
	weapon.queue_free()
	weapon = weapons_scn[weapon_idx].instance()
	add_child(weapon)
	emit_signal("weapon_changed", weapon)

func switch_build_mode():
	if build_mode:
		weapon.clear_preview_block()
		change_weapon_by_weapon_idx(picked_weapon)
		build_mode = false
	else:
		weapon.queue_free()
		weapon = builder_arm_scn.instance()
		add_child(weapon)
		build_mode = true
		emit_signal("weapon_changed", weapon)

func handle_head_damage():
	hp.take_damage(1)
	play_hurt_sound()

func handle_fall_damage():
	hp.take_damage((on_air_time - MIN_AIRBONE_TIME_FALL_DAMAGE) * 10)
	play_hurt_sound()

func play_hurt_sound():
	# Beware: needs to be manually changed when adding or removing sounds.
	# May be improved.
	var pick = round(rand_range(0.5,10.5))
	if not sound_voice.is_voice_active(0):
		sound_voice.play("cri" + str(pick))

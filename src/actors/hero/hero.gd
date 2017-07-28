extends "../creature.gd"


# nodes attributes

onready var body_sprite = get_node("body")
onready var arm_right_position = get_node("body/arm_right")
onready var arm_left_position = get_node("body/arm_left")
onready var weapon = get_node("weapon")
onready var camera = get_node("camera")
onready var anim = get_node("anim")
onready var sound_voice = get_node("voice")
onready var sound_bones = get_node("bones")

# weapons attributes
var picked_weapon = 0

enum { ID, WEAPON}
var carried_weapons = [
	[Weapons.PISTOL, Weapons.weapons_scn[Weapons.PISTOL].instance()],
	[Weapons.MACHINE_GUN, Weapons.weapons_scn[Weapons.MACHINE_GUN].instance()],
	[Weapons.SHOTGUN, Weapons.weapons_scn[Weapons.SHOTGUN].instance()],
	[Weapons.DYNAMITE, Weapons.weapons_scn[Weapons.DYNAMITE].instance()],
	[Weapons.BUBBLE_GUN, Weapons.weapons_scn[Weapons.BUBBLE_GUN].instance()]
]

enum { AMMO, MAX_AMMO}

var ammunition = [
	[0,-1], # pistol
	[30,30], # dirt gun
	[250,250], # uzi
	[25,25], # shotgun
	[150,150], # machine gun
	[15,15], # grenade launcher
	[20,20], # timed grenade launcher
	[5,5], # dynamite
	[50,50], # bubble gun
	[0,-1]  # sword
]

signal weapon_status_update(name, ammo, maximum_ammo)

# build attributes
var builder_arm_scn = preload("construction/builder_arm.tscn")
var builder_arm
var build_mode = false

# other
var attack_pressed_timestamp = 0
var killed = false

func _ready():
	set_process_input(true)
	set_process(true)

	hp.connect("on_damage", self, "handle_damage")


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
		if weapon.mode == weapon.SEMI_AUTO_MODE :
			if event.is_action_pressed("attack"):
				attack_pressed_timestamp = OS.get_ticks_msec()
			elif event.is_action_released("attack"):
				var time_pressed = (OS.get_ticks_msec() - attack_pressed_timestamp) / 1000.0
				var used_ammunition = required_ammunition(time_pressed)

				if used_ammunition <= ammunition[carried_weapons[picked_weapon][ID]][AMMO]:
					weapon.fire(time_pressed)
				else:
					if(!weapon.fire_sound.is_voice_active(0)): # 0 is the number of the sound "fire"
						weapon.fire_sound.play("empty_magazine")

		# weapon switching
		if event.is_action_pressed("next_weapon"):
			picked_weapon = (picked_weapon + 1) % carried_weapons.size()
			change_weapon_by_weapon_idx(picked_weapon)
		elif event.is_action_pressed("previous_weapon"):
			picked_weapon = (picked_weapon - 1) % carried_weapons.size()
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
	anim.play("death")

func _pre_fixed_process(delta):
	if build_mode:
		if Input.is_action_pressed("secondary_action"):
			weapon.remove_block()
	else:
		if weapon.mode == weapon.AUTOMATIC_MODE:
			if Input.is_action_pressed("attack"):
				weapon.fire(0)

	set_go_left(Input.is_action_pressed("move_left"))
	set_go_right(Input.is_action_pressed("move_right"))
	set_jump(Input.is_action_pressed("jump"))

func _take_head_damage():
	play_hurt_sound()
	sound_bones.play("bone_break")
	hp.take_damage(1)

func _take_fall_damage():
	play_hurt_sound()
	sound_bones.play("bone_break")
	hp.take_damage((velocity.y - MIN_VELOCITY_FALL_DAMAGE) / 10.0)

func handle_damage(hp):
	play_hurt_sound()
	anim.play("damage")

func play_hurt_sound():
	# Beware: needs to be manually changed when adding or removing sounds.
	# May be improved.
	var pick = round(rand_range(0.5,10.5))
	if not sound_voice.is_voice_active(0):
		sound_voice.play("cri" + str(pick))

# weapon related functions
func change_weapon_by_weapon_idx(weapon_idx):
	remove_child(weapon)
	weapon = carried_weapons[weapon_idx][WEAPON]
	add_child(weapon)
	emit_signal("weapon_status_update", weapon.name,
	ammunition[carried_weapons[picked_weapon][ID]][AMMO],
	ammunition[carried_weapons[picked_weapon][ID]][MAX_AMMO])

func switch_build_mode():
	if build_mode:
		weapon.clear_preview_block()
		change_weapon_by_weapon_idx(picked_weapon)
		build_mode = false
	else:
		remove_child(weapon)
		weapon = builder_arm
		add_child(weapon)
		build_mode = true
		emit_signal("weapon_status_update", weapon.name, 0,-1)

func _instanciate_weapons():
	builder_arm = builder_arm_scn.instance()
	for weapons in carried_weapons:
		weapons[WEAPON].connect("shot",self,"update_ammunition")

	emit_signal(
	"weapon_status_update",
	weapon.name,
	ammunition[carried_weapons[picked_weapon][ID]][AMMO],
	ammunition[carried_weapons[picked_weapon][ID]][MAX_AMMO])

func required_ammunition(time_pressed):
	if ammunition[carried_weapons[picked_weapon][ID]][MAX_AMMO] != -1:
		if carried_weapons[picked_weapon][ID] != Weapons.BUBBLE_GUN:
			return 1
		else:
			if time_pressed >= weapon.full_intensity_time:
				return 5
			else:
				return round(1 + 4*time_pressed/weapon.full_intensity_time)
	else:
		return 0

func update_ammunition(time_pressed):
	ammunition[carried_weapons[picked_weapon][ID]][AMMO] -= required_ammunition(time_pressed)

	emit_signal(
	"weapon_status_update",
	weapon.name,
	ammunition[carried_weapons[picked_weapon][ID]][AMMO],
	ammunition[carried_weapons[picked_weapon][ID]][MAX_AMMO])

func add_ammunition(weapon_id, quantity):
	if (ammunition[weapon_id][AMMO] + quantity) >= ammunition[weapon_id][MAX_AMMO]:
		ammunition[weapon_id][AMMO] = ammunition[weapon_id][MAX_AMMO]
	else:
		ammunition[weapon_id][AMMO] += quantity

func add_weapon(weapon_id):
	var new_weapon = Weapons.weapons_scn[weapon_id].instance()
	new_weapon.connect("shot",self,"update_ammunition")
	carried_weapons.append(new_weapon)

func remove_weapon(weapon_id):
	for weapons in carried_weapons:
		if weapons[ID] == weapon_id:
			weapons[WEAPON].queue_free()
			carried_weapons.erase(weapons)


func has_weapon(weapon_id):
	for weapons in carried_weapons:
		if weapons[ID] == weapon_id:
			return true
	return false
extends Node

# list of the enemies
enum {
	ENEMY
}

# wave modes
enum {
	GARRISON_EXHAUSTION,
	TIME_SURVIVAL
}

# list of the available enemies with the available number at the corresponding index
var available_mole = [10]

# wave
var wave_number = 0
var wave_mode = GARRISON_EXHAUSTION

var max_mole_count
var mole_count
var rifts # the rifts throughout the map
var rift_scn = preload("./rift.tscn")

var alive_rifts # number of rifts alive

signal no_rift() # emitted when there are no rift alive
signal count_update(ratio)
signal mole_spawned(mole)

func _ready():
	max_mole_count = get_available_moles()
	mole_count = max_mole_count

	rifts = get_children()
	alive_rifts = rifts.size()

	connect("no_rift",self,"wave_end")
	instanciate_rifts()

	# test
	add_garrison_to_rift(0,ENEMY,5)
	add_garrison_to_rift(1,ENEMY,5)
	spawn_from_rift(0,ENEMY,5)
	spawn_from_rift(1,ENEMY,5)

# moles management
func spawn_from_rift(rift_idx, mole_idx, quantity): # spawned units have to be in rift's garrison
	rifts[rift_idx].add_to_queue(mole_idx,quantity)

func add_garrison_to_rift(rift_idx, mole_idx, quantity):
	var available_mole_bis = available_mole[mole_idx]
	if available_mole_bis >= quantity :
		rifts[rift_idx].add_to_garrison(mole_idx, quantity)

		available_mole[mole_idx] -= quantity
	elif(available_mole_bis != 0 and quantity >= available_mole_bis):
		rifts[rift_idx].add_to_garrison(mole_idx, available_mole_bis)

		available_mole[mole_idx] = 0
		print("[Warning] Attempt to add more moles to garrison than available")
	else:
		print("[Warning] Attempt to add more moles to garrison when none available")

# rift creation functions ===================
func add_rift(pos):
	var new_rift = rift_scn.instance()
	new_rift.set_pos(pos)
	new_rift.connect("dead", self, "dead_rift")
	new_rift.connect("lost_a_mole", self, "update_mole_count")
	new_rift.connect("mole_spawned", self, "_mole_spawned")
	new_rift.create_rift_room()
	add_child(new_rift)

	rifts.append(new_rift)

func add_damageable_rift(pos):
	var new_rift = rift_scn.instance()
	new_rift.hp.invicible = false
	new_rift.set_pos(pos)
	add_child(new_rift)


func dead_rift():
	alive_rifts -= 1
	if alive_rifts == 0:
		emit_signal("no_rift")

func create_rift_rooms():
	for rift in rifts:
		rift.create_rift_room()

# others

func get_available_moles():
	var S = 0
	for mole in available_mole:
		S += mole
	return S

func update_mole_count():
	mole_count -= 1
	var ratio = mole_count / float(max_mole_count)
	emit_signal("count_update",ratio)

func wave_end():
	print("The moles are vanquished!!! Praise the rabbit! Praise the carrot!")


func _mole_spawned(mole):
	emit_signal("mole_spawned", mole)

func instanciate_rifts():
	for rift in rifts:
		rift.connect("dead", self, "dead_rift")
		rift.connect("lost_a_mole", self, "update_mole_count")
		rift.connect("mole_spawned", self, "_mole_spawned")
	create_rift_rooms()
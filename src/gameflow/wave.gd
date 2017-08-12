extends Node

var mole_value = [
	6 # WEAKLING
]
var wave_reward

# wave modes
enum {
	GARRISON_EXHAUSTION,
	TIME_SURVIVAL
}

# list of the available enemies with the available number at the corresponding index
var available_mole = []

# wave
var wave_mode = GARRISON_EXHAUSTION

var max_mole_count = 0
var mole_count
var rifts # the rifts throughout the map
var rift_scn = preload("./rift.tscn")

var alive_rifts = 0 # number of rifts alive

signal no_rift(reward) # emitted when there are no rift alive
signal count_update(ratio)
signal mole_spawned(mole)

func _ready():
	rifts = get_children()
	instanciate_rifts()

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
	new_rift.connect("alive",self,"add_alive_rift")
	new_rift.connect("lost_a_mole", self, "update_mole_count")
	new_rift.connect("mole_spawned", self, "_mole_spawned")
	add_child(new_rift)

	new_rift.create_rift_room()
	rifts.append(new_rift)

func add_damageable_rift(pos):
	var new_rift = rift_scn.instance()
	new_rift.hp.invicible = false
	new_rift.set_pos(pos)
	add_child(new_rift)

func add_alive_rift():
	alive_rifts += 1

func dead_rift():
	print("boom")
	alive_rifts -= 1
	if alive_rifts == 0:
		print("fini")
		emit_signal("no_rift", wave_reward)

func create_rift_rooms():
	for rift in rifts:
		rift.create_rift_room()

# others

func evaluate_reward():
	wave_reward = 0
	for i in range(available_mole.size()):
		wave_reward += available_mole[i]*mole_value[i]
	return wave_reward

func evaluate_available_moles():
	var S = 0
	for mole in available_mole:
		S += mole
	return S

func initiate_mole_count():
	max_mole_count = evaluate_available_moles()
	mole_count = max_mole_count


func update_mole_count():
	mole_count -= 1
	var ratio = mole_count / float(max_mole_count)

	emit_signal("count_update",ratio)


func _mole_spawned(mole):
	emit_signal("mole_spawned", mole)

func instanciate_rifts():
	for rift in rifts:
		rift.connect("dead", self, "dead_rift")
		rift.connect("alive",self,"add_alive_rift")
		rift.connect("lost_a_mole", self, "update_mole_count")
		rift.connect("mole_spawned", self, "_mole_spawned")
	create_rift_rooms()
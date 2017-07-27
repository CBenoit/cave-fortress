extends Sprite

# list of all the enemies
var moles = [
	preload("res://actors/enemy/enemy.tscn")
]

# list containing the number of mole in the garrison
var garrison = []
var alive = false

signal lost_a_mole()
signal dead()
signal mole_spawned(mole)

# mole healed by the healing_area
var healing_area
var healed_mole = []

# management of the mole spawn
var spawn_queue = []
var empty_queue = true
var mole_count = 0

var timer

# others
var hp
var solids_tilemaps

func _ready():
	solids_tilemaps = get_node("../../solids")
	healing_area = get_node("healing_area")


	timer = get_node("Timer")

	hp = get_node("hp")
	if (hp.invicible == false):
		set_modulate(Color(0.2,0.8,0.2))

	initiate_garrison()

	healing_area.connect("body_enter",self,"heal_mole")
	healing_area.connect("body_exit",self,"stop_healing")
	timer.connect("timeout",self,"queue_spawn")

func _fixed_process(delta):

	for mole in healed_mole:
		var mole_hp = mole.hp.max_health
		mole.hp.restore_hp(0.01*mole_hp)


# queue function ==================

func queue_spawn(): # spawn the first mole in the queue
	var mole = spawn_queue[0].instance()
	mole.set_pos(get_pos() - Vector2(0,32))
	get_node("../../entities").add_child(mole)
	mole.hp.connect("killed",self,"mole_number_update")

	spawn_queue.remove(0)
	mole_count += 1

	emit_signal("mole_spawned", mole)

	if spawn_queue.size() == 0:
		change_queue_status()

func add_to_queue(mole_idx, quantity):
	var mole_garrison = garrison[mole_idx]
	if mole_garrison >= quantity:
		for i in range(quantity):
			spawn_queue.append(moles[mole_idx])
		garrison[mole_idx] -= quantity
	elif(mole_garrison != 0 and quantity >=  mole_garrison):
		for i in range(mole_garrison):
			spawn_queue.append(moles[mole_idx])
		garrison[mole_idx] = 0

		print("[Warning] Attempt to spawn more units than available ones")
	else:
		print("[Warning] Attempt to spawn unavailable units")

	if empty_queue: # we stop the timer if there are no more enemies
		change_queue_status()

func mole_number_update():
	mole_count -= 1
	emit_signal("lost_a_mole")
	if (mole_count == 0 and garrison_left() == 0): # a rift is dead if no moles are attached to it and no garrison
		alive = false
		set_fixed_process(false)
		emit_signal("dead")

func change_queue_status():
	if empty_queue:
		empty_queue = false
		timer.start()
	else:
		empty_queue = true
		timer.stop()

# garrison functions ================

func add_to_garrison(mole_idx, quantity):
	garrison[mole_idx] += quantity
	alive = true
	set_fixed_process(true)

func initiate_garrison():
	for mole in moles:
		garrison.append(0)

func garrison_left():
	var S = 0
	for moles in garrison:
		S += moles
	return S

func empty_garrison():
	for i in range(garrison.size()):
		garrison[i] = 0

 # heal functions =================
func heal_mole(mole):
	if "creature" in mole.get_groups(): # checking if the mole is not a filthy tilemap
		if (mole.team == 2): # checking if the mole is not a rabbit
			healed_mole.append(mole)

func stop_healing(mole):
	healed_mole.erase(mole)

# ===== rift creation

func create_rift_room():
	var pos = get_pos()
	var tile_size = SolidTiles.TILE_SIZE

	for x in range(pos.x - 3*tile_size,pos.x + 3*tile_size, tile_size):
		for y in range(pos.y -2*tile_size, pos.y + 2*tile_size, tile_size):
			solids_tilemaps.set_cellv(solids_tilemaps.world_to_map(Vector2(x,y)),SolidTiles.TILE_EMPTY)

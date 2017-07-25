extends Sprite



# list of all the enemies
var moles = [
	preload("res://actors/enemy/enemy.tscn")
]

# list containing the number of mole in the garrison
var garrison = []

# mole healed by the healing_area
var healing_area
var healed_mole = []


func _ready():
	healing_area = get_node("healing_area")
	get_node("Timer").connect("timeout",self,"poop")



	if (get_node("hp").invicible == false):
		set_modulate(Color(0.2,0.8,0.2))

	initiate_garrison()
	set_fixed_process(true)

	healing_area.connect("body_enter",self,"heal_mole")
	healing_area.connect("body_exit",self,"stop_healing")

func _fixed_process(delta):

	for mole in healed_mole:
		var mole_hp = mole.hp.max_health
		mole.hp.restore_hp(0.01*mole_hp)



func spawn(mole_idx):
	if (garrison[mole_idx] > 0):
		var mole = moles[mole_idx].instance()
		mole.set_pos(get_pos() - Vector2(0,32))
		get_node("../../entities").add_child(mole)

		garrison[mole_idx] -= 1
	else:
		print("[Warning] Attempt to spawn unavailable unit")

func add_to_garrison(mole_idx, quantity):
	garrison[mole_idx] += quantity

func empty_rift():
	for i in range(garrison.size()):
		garrison[i] = 0

func heal_mole(mole):
	if "creature" in mole.get_groups(): # checking if the mole is not a filthy tilemap
		if (mole.team == 2): # checking if the mole is not a rabbit
			healed_mole.append(mole)

func stop_healing(mole):
	healed_mole.erase(mole)

func initiate_garrison():
	for mole in moles:
		garrison.append(5)

func poop():
	spawn(0)
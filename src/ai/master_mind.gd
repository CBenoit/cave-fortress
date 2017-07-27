extends Node

var PlatformerAStar = preload("res://ai/pathfinding/PlatformerAStar.gd")

onready var wave = get_node("../content/wave")
onready var solids = get_node("../content/solids")

var _moles = []
var _mole_update_idx = 0

onready var astar = PlatformerAStar.new(solids)

func _ready():
	set_fixed_process(true)

	wave.connect("mole_spawned", self, "_mole_spawned")

func _fixed_process(delta):
	if get_tree().get_frame() % 25 == 0:
		if not _moles.empty():
			_mole_update_idx = (_mole_update_idx + 1) % _moles.size()
			_moles[_mole_update_idx].update_ai(astar)

func _mole_spawned(mole):
	_moles.append(mole)
	mole.hp.connect("killed", self, "_mole_dead", [mole])

func _mole_dead(mole):
	_moles.erase(mole)

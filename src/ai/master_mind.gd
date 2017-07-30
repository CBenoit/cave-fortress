extends Node

const ACTION_UPDATE_FREQUENCY = 7
const DECISION_UPDATE_FREQUENCY = 16
const PATH_UPDATE_FREQUENCY = 17
const PATHFINDING_PROCESS_FREQUENCY = 3

var PlatformerAStar = preload("res://ai/pathfinding/PlatformerAStar.gd")

onready var wave = get_node("../content/wave")
onready var solids = get_node("../content/solids")

var _frame = 0
var _moles = []
var _mole_path_update_idx = 0
var _path_processing_mole = null

onready var astar = PlatformerAStar.new(solids)

func _ready():
	set_process(true)

	wave.connect("mole_spawned", self, "_mole_spawned")

func _process(delta):
	# this part act as a scheduler for moles AI
	_frame += 1

	if _frame % PATH_UPDATE_FREQUENCY == 0:
		if not _moles.empty():
			_mole_path_update_idx = (_mole_path_update_idx + 1) % _moles.size()
			_moles[_mole_path_update_idx].update_path(astar)
			_path_processing_mole = _moles[_mole_path_update_idx]

	if _frame % PATHFINDING_PROCESS_FREQUENCY == 0 and _path_processing_mole != null:
		_path_processing_mole.process_path()

	var i = 0
	while i < _moles.size():
		if (_frame + i) % DECISION_UPDATE_FREQUENCY == 0:
			_moles[i].update_decision()

		if (_frame + i) % ACTION_UPDATE_FREQUENCY == 0:
			_moles[i].update_action()

		i += 1
	# ===== moles AI part =====

func _mole_spawned(mole):
	_moles.append(mole)
	mole.hp.connect("killed", self, "_mole_dead", [mole])

func _mole_dead(mole):
	if _path_processing_mole == mole:
		_path_processing_mole = null
	_moles.erase(mole)

extends Label

onready var timer = get_node("Timer")

func _ready():
	timer.connect("timeout",self,"change_state")

func change_state():
	set_hidden(!is_hidden())

func set_active( state):
	timer.set_active(state)
	set_hidden(true)
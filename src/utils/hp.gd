extends Node

export(float,1,1000,1) var max_health = 30
export(bool) var invicible = false

var health

signal killed()
signal on_damage(hp)

func _ready():
	health = max_health

func is_dead():
	return health <= 0

func take_damage(damage):
	if(!invicible):
		health -= damage
		emit_signal("on_damage", self)
		if is_dead():
			emit_signal("killed")

func restore_hp(value):
	if (value + health >= max_health):
		health = max_health
	else:
		health += value

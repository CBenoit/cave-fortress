extends Node2D


export(float,1,1000,1) var max_health = 30
export(bool) var invicible = false

var health

signal killed()
signal on_damage()

func _ready():
	health = max_health


func take_damage(damage):
	if(!invicible):
		emit_signal("on_damage")
		health -= damage
		if health <= 0:
			emit_signal("killed")

func restore_hp(value):
	if (value + health >= max_health):
		health = max_health
	else:
		health += value


extends StaticBody2D

export var max_health = 10

var health = max_health

func damage(value):
	health -= value
	if health <= 0:
		queue_free()

func repair(value):
	health += value
	if health > max_health:
		health = max_health

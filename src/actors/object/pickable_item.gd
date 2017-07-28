extends RigidBody2D

onready var sprite = get_node("sprite")
onready var item_info = get_node("item_info")
onready var pick_zone = get_node("pick_zone")


var to_free = false

func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	var colliders = pick_zone.get_overlapping_bodies()
	for collider in colliders:
		var gp = collider.get_groups()
		if "creature" in gp:
			add_collision_exception_with(collider)
			if "player" in gp:
				_pick(collider)

	if to_free:
		queue_free()


func _pick(collider):
	pass

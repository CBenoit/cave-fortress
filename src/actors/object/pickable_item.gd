extends RigidBody2D

onready var sprite = get_node("sprite")
onready var item_info = get_node("item_info")
onready var pick_zone = get_node("pick_zone")
onready var timer = get_node("Timer")
onready var sound_effect = preload("res://effects/picked_effect.tscn").instance()

# used to allow player to drop the weapon
# if there wasn't a delay for the item to be picked after spawn, it would be taken back right away
var locked = true


func _ready():
	timer.connect("timeout",self,"open_lock")

	set_fixed_process(true)

func _fixed_process(delta):
	var colliders = pick_zone.get_overlapping_bodies()
	for collider in colliders:
		var gp = collider.get_groups()
		if "creature" in gp:
			add_collision_exception_with(collider)
			if "player" in gp and not locked:
				_pick(collider)



func open_lock():
	locked = false

func _pick(collider):
	pass

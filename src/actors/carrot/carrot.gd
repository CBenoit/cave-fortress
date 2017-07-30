extends "../creature.gd"


var carrot_x
var health_bar

func _ready():
	carrot_x = get_pos().x

	health_bar = get_node("health_bar")

	hp.connect("on_damage",self, "update_health_bar")


func _post_fixed_process(delta):
	set_pos(Vector2(carrot_x,get_pos().y))


func _die():
	queue_free()

func update_health_bar(new_hp):
	health_bar.set_value(100*new_hp.health/new_hp.max_health)

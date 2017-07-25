extends "../creature.gd"


var carrot_x

func _ready():
	carrot_x = get_pos().x


func _post_fixed_process(delta):

	set_pos(Vector2(carrot_x,get_pos().y))


func _die():
	queue_free()


extends "../abstract_screen.gd"

var content
var test_level = preload("res://levels/level_test.tscn")

func _ready():
	content = get_node("content")
	content.add_child(test_level.instance())

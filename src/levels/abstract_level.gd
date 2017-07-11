extends Node

var current_wave = 0
var level_area
var base_area

func _ready():
	level_area = get_node("level_area")
	base_area = get_node("base_area")
	fill_area_outside_base()

func fill_area_outside_base():
	var top_left = -level_area.get_scale() / 2
	#top_left.x =

extends Node2D

var PlatformerAStar = load("res://ai/pathfinding/PlatformerAStar.gd")

export(NodePath) var node_path_solids_tilemap
export(NodePath) var node_path_from_node

onready var solids_tilemap = get_node(node_path_solids_tilemap)
onready var from_node = get_node(node_path_from_node)

onready var astar = PlatformerAStar.new(solids_tilemap)
var path_query
var path_to_follow = []

func _ready():
	set_process_input(true)

func _process(delta):
	path_query = path_query.resume()
	if typeof(path_query) == TYPE_ARRAY:
		path_to_follow = path_query
		path_query = null
		update()
		set_process(false)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and path_query == null:
		path_query = astar.query_path(
			solids_tilemap.world_to_map(from_node.get_pos()),
			solids_tilemap.world_to_map(get_local_mouse_pos()),
			2,
			30
		)

		if typeof(path_query) == TYPE_ARRAY:
			path_to_follow = path_query
			update()
		else:
			set_process(true)

func _draw():
	for waypoint in path_to_follow:
		draw_circle(solids_tilemap.map_to_world(waypoint) + Vector2(16, 16), 3, Color(1, 0, 0))

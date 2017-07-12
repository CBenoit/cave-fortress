extends Node

const TILE_STONE = 0
const TILE_DIRT = 1
const TILE_STEEL = 2

var current_wave = 0
var topleft_level_area
var bottomright_level_area
var topleft_base_area
var bottomright_base_area
var solids_tilemap

func _ready():
	topleft_level_area = get_node("topleft_level_area")
	bottomright_level_area = get_node("bottomright_level_area")
	topleft_base_area = get_node("topleft_base_area")
	bottomright_base_area = get_node("bottomright_base_area")
	solids_tilemap = get_node("content/solids")

	discretize_position_on_32x32(topleft_level_area)
	discretize_position_on_32x32(bottomright_level_area)
	discretize_position_on_32x32(topleft_base_area)
	discretize_position_on_32x32(bottomright_base_area)

	fill_area_outside_base()

func fill_area_outside_base():
	for x in range(topleft_level_area.get_pos().x, bottomright_level_area.get_pos().x, 32):
		for y in range(topleft_level_area.get_pos().y, bottomright_level_area.get_pos().y, 32):
			if not contained_in_base(Vector2(x, y)):
				var tile_x = x / 32
				var tile_y = y / 32

				var selected_tile = TILE_DIRT
				var stone_probability = 0.1
				if TILE_STONE in get_neighbour_tiles(tile_x, tile_y):
					stone_probability = 0.4
				if randf() < stone_probability:
					selected_tile = TILE_STONE

				solids_tilemap.set_cell(x / 32, y / 32, selected_tile)

func discretize_position_on_32x32(pos):
	var vec = pos.get_pos()
	vec.x = vec.x - int(vec.x) % 32
	vec.y = vec.y - int(vec.y) % 32
	pos.set_pos(vec)

func contained_in_base(pos):
	return pos.x > topleft_base_area.get_pos().x and pos.x < bottomright_base_area.get_pos().x \
		and pos.y > topleft_base_area.get_pos().y and pos.y < bottomright_base_area.get_pos().y

func get_neighbour_tiles(x, y):
	return [solids_tilemap.get_cell(x - 1, y),
			solids_tilemap.get_cell(x + 1, y),
			solids_tilemap.get_cell(x, y - 1),
			solids_tilemap.get_cell(x, y + 1)]

extends Node

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

	var hero_camera = get_node("content/entities/hero/camera")
	hero_camera.set_limit(MARGIN_LEFT, topleft_level_area.get_pos().x)
	hero_camera.set_limit(MARGIN_TOP, topleft_level_area.get_pos().y)
	hero_camera.set_limit(MARGIN_RIGHT, bottomright_level_area.get_pos().x)
	hero_camera.set_limit(MARGIN_BOTTOM, bottomright_level_area.get_pos().y)

	fill_area_outside_base()

func fill_area_outside_base():
	for x in range(topleft_level_area.get_pos().x, bottomright_level_area.get_pos().x, 32):
		for y in range(topleft_level_area.get_pos().y, bottomright_level_area.get_pos().y, 32):
			var pos = Vector2(x, y)
			if not contained_in_base(pos):
				var tile_pos = solids_tilemap.world_to_map(pos)

				var selected_tile = SolidTiles.TILE_DIRT
				var stone_probability = 0.1
				if SolidTiles.TILE_STONE in get_neighbour_tiles(tile_pos):
					stone_probability = 0.4

				if randf() < stone_probability:
					selected_tile = SolidTiles.TILE_STONE
				elif randf() < 0.01: # very small probability of steel
					selected_tile = SolidTiles.TILE_STEEL

				solids_tilemap.set_cellv(tile_pos, selected_tile)

func contained_in_base(pos):
	return pos.x > topleft_base_area.get_pos().x and pos.x < bottomright_base_area.get_pos().x \
		and pos.y > topleft_base_area.get_pos().y and pos.y < bottomright_base_area.get_pos().y

func get_neighbour_tiles(tile_pos):
	return [solids_tilemap.get_cell(tile_pos.x - 1, tile_pos.y),
			solids_tilemap.get_cell(tile_pos.x + 1, tile_pos.y),
			solids_tilemap.get_cell(tile_pos.x, tile_pos.y - 1),
			solids_tilemap.get_cell(tile_pos.x, tile_pos.y + 1)]

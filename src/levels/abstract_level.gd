extends Node

var current_wave = 0
var topleft_level_area
var bottomright_level_area
var topleft_base_area
var bottomright_base_area
var solids_tilemap
var background_tilemap
var hero
var hud
var wave

func _ready():
	topleft_level_area = get_node("topleft_level_area")
	bottomright_level_area = get_node("bottomright_level_area")
	topleft_base_area = get_node("topleft_base_area")
	bottomright_base_area = get_node("bottomright_base_area")
	solids_tilemap = get_node("content/solids")
	background_tilemap = get_node("content/ParallaxBackground/ParallaxLayer/background")
	hero = get_node("content/entities/hero")
	hud = get_node("game_hud")
	wave = get_node("content/wave")

	var hero_camera = get_node("content/entities/hero/camera")
	hero_camera.set_limit(MARGIN_LEFT, topleft_level_area.get_pos().x)
	hero_camera.set_limit(MARGIN_TOP, topleft_level_area.get_pos().y)
	hero_camera.set_limit(MARGIN_RIGHT, bottomright_level_area.get_pos().x)
	hero_camera.set_limit(MARGIN_BOTTOM, bottomright_level_area.get_pos().y)

	fill_outside_base()
	generate_background()

	# connect signals
	hero.connect("weapon_status_update",hud,"update_weapon_hud")
	hero.hp.connect("on_damage", hud, "hp_changed")
	wave.connect("count_update",hud,"wave_update")

	instanciate()

func fill_outside_base(): # filling the map outside the base area
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


func generate_background(): # generates the background
	for x in range(topleft_level_area.get_pos().x, bottomright_level_area.get_pos().x, 32):
		for y in range(topleft_level_area.get_pos().y, bottomright_level_area.get_pos().y, 32):
			var tile_pos = solids_tilemap.world_to_map(Vector2(x,y))
			background_tilemap.set_cellv(tile_pos, floor(rand_range(0,5))) # placing the background texture

func contained_in_base(pos):
	return pos.x > topleft_base_area.get_pos().x and pos.x < bottomright_base_area.get_pos().x \
		and pos.y > topleft_base_area.get_pos().y and pos.y < bottomright_base_area.get_pos().y

func get_neighbour_tiles(tile_pos):
	return [solids_tilemap.get_cell(tile_pos.x - 1, tile_pos.y),
			solids_tilemap.get_cell(tile_pos.x + 1, tile_pos.y),
			solids_tilemap.get_cell(tile_pos.x, tile_pos.y - 1),
			solids_tilemap.get_cell(tile_pos.x, tile_pos.y + 1)]


# instanciate several components of the games that requires to be done after everything is ready
func instanciate():
	wave._instanciate_rifts()
	hero._instanciate_weapons()


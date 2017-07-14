extends TileMap

var fissures_scn = preload("./fissures/fissures.tscn")

var tiles_damages = {}

func damage_tile(tile_pos, damages):
	if get_cellv(tile_pos) == SolidTiles.TILE_EMPTY:
		return # should not happen...

	if tiles_damages.has(tile_pos):
		tiles_damages[tile_pos].decrease_tile_health(damages)
	else:
		# create fissures
		var fissures = fissures_scn.instance()
		fissures.set_pos(map_to_world(tile_pos))
		var this_tile_max_health = SolidTiles.TILE_HEALTH[get_cellv(tile_pos)]
		fissures.init(this_tile_max_health, this_tile_max_health - damages)
		tiles_damages[tile_pos] = fissures
		add_child(fissures)

	if tiles_damages[tile_pos].get_tile_health() <= 0:
		set_cellv(tile_pos, SolidTiles.TILE_EMPTY)
		tiles_damages.erase(tile_pos) # free the memory

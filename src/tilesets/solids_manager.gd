extends TileMap

var tiles_damages = {}

func damage_tile(tile_pos, damages):
	if tiles_damages.has(tile_pos):
		tiles_damages[tile_pos] -= damages
	else:
		tiles_damages[tile_pos] = SolidTiles.TILE_HEALTH[get_cellv(tile_pos)] - damages

	if tiles_damages[tile_pos] <= 0:
		set_cellv(tile_pos, SolidTiles.TILE_EMPTY)
		tiles_damages.erase(tile_pos) # free the memory

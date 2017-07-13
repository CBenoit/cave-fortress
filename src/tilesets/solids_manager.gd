extends TileMap

func damage_tile(tile_pos):
	set_cellv(tile_pos, SolidTiles.TILE_EMPTY)

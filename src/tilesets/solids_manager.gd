extends TileMap

# other scenes

var fissures_scn = preload("./fissures/fissures.tscn")
var block_destruction_effect_scn = preload("res://effects/block_destruction.tscn")

var tiles_damages = {}

func build_tile(tile_pos, tile_type):
	set_cellv(tile_pos, tile_type)

func damage_tile(tile_pos, damages):
	if damages <= 0:
		print("[WARNING] Attempted to deal 0 damage to tile at position", tile_pos, ".")
		return

	if get_cellv(tile_pos) == SolidTiles.TILE_EMPTY:
		return

	if tiles_damages.has(tile_pos):
		tiles_damages[tile_pos].decrease_tile_health(damages)
		if tiles_damages[tile_pos].get_tile_health() <= 0:
			_destruct_tile(tile_pos)
			tiles_damages[tile_pos].queue_free()
			tiles_damages.erase(tile_pos) # free the memory
	else:
		var this_tile_max_health = SolidTiles.TILE_HEALTH[get_cellv(tile_pos)]
		if this_tile_max_health - damages <= 0:
			_destruct_tile(tile_pos)
			return

		# tile is not yet totally destroyed, create fissures
		var fissures = fissures_scn.instance()
		fissures.set_pos(map_to_world(tile_pos))
		fissures.init(this_tile_max_health, this_tile_max_health - damages)
		tiles_damages[tile_pos] = fissures
		add_child(fissures)

func _destruct_tile(tile_pos):
	# spawn destruction effect
	var texture = get_tileset().tile_get_texture(get_cellv(tile_pos))
	var region = get_tileset().tile_get_region(get_cellv(tile_pos))
	var color = texture.get_data().get_pixel(
		region.pos.x + randi() % int(region.size.x),
		region.pos.y + randi() % int(region.size.y)
	)

	var effect = block_destruction_effect_scn.instance()
	effect.set_pos(map_to_world(tile_pos) + Vector2(SolidTiles.TILE_SIZE / 2, SolidTiles.TILE_SIZE / 2))
	effect.set_color(color)
	get_node("../").add_child(effect)
	effect.activate()

	# remove the tile
	set_cellv(tile_pos, SolidTiles.TILE_EMPTY)

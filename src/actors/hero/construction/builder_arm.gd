extends Sprite

# properties
export(float,64,512,1) var reach = 96
export(float,0,2,0.05) var build_lapse = 0.0 # in seconds
var name = "builder arm"

var solids_tilemap

var preview_block_scn = preload("preview_block.tscn")
var preview_block

# used to order the tile switch and display a correct preview
var tile_creation_switch = [
	SolidTiles.TILE_DIRT,
	SolidTiles.TILE_STONE,
	SolidTiles.TILE_STEEL
]
var picked_tile = 0
var mouse_pos
var tile_at_pos
var distance
var can_build = false
var timestamp_last_build = 0

func _ready():
	solids_tilemap = get_node("../../../solids")
	preview_block = preview_block_scn.instance()
	get_node("../../../../content").add_child(preview_block)

	set_fixed_process(true)

func _fixed_process(delta):
	mouse_pos = get_global_mouse_pos()

	# in the grid of the tilemap
	preview_block.set_global_pos(Vector2(closest_multiple(mouse_pos.x, SolidTiles.TILE_SIZE), closest_multiple(mouse_pos.y, SolidTiles.TILE_SIZE)))

	# distance between the player and placement position
	distance = (preview_block.get_global_pos() + Vector2(SolidTiles.TILE_SIZE / 2, SolidTiles.TILE_SIZE / 2) - get_global_pos()).length()
	tile_at_pos = solids_tilemap.get_cellv(solids_tilemap.world_to_map(mouse_pos))

	# TODO: maybe add raycasting?
	if (tile_at_pos == SolidTiles.TILE_EMPTY and distance < reach):
		preview_block.set_opacity(0.8)
		preview_block.set_modulate(Color(0.2, 1, 0.2)) # adding a layer of green over the block if it can be placed
		can_build = true
	elif (distance < reach): # destruction mode
		preview_block.set_opacity(0.2)
		preview_block.set_modulate(Color(5, 0.2, 0.2)) # red if within reach but can't place block
		can_build = false
	else:
		preview_block.set_opacity(0.2)
		preview_block.set_modulate(Color(0.6, 0.6, 0.6)) # grey if out of reach
		can_build = false

func create_block():
	if timestamp_last_build + build_lapse * 1000 <= OS.get_ticks_msec() and can_build:
		timestamp_last_build = OS.get_ticks_msec()
		#build_sound.play("zap")
		solids_tilemap.set_cellv(solids_tilemap.world_to_map(preview_block.get_pos()), tile_creation_switch[picked_tile])

func remove_block():
	if distance < reach:
		solids_tilemap.damage_tile(solids_tilemap.world_to_map(mouse_pos),0.07*SolidTiles.TILE_HEALTH[tile_at_pos])

func change_picked_tile(step): # step should be either 1 or -1, will be used in the tile switch
	# because just -1 % 3 gives -1 and not 2, so we add +3.
	picked_tile = (picked_tile + step + tile_creation_switch.size()) % tile_creation_switch.size()
	preview_block.set_frame(picked_tile)

func closest_multiple(x, y): # closest multiple of y to x
	return floor(x / y) * y

func clear_preview_block():
	preview_block.queue_free()

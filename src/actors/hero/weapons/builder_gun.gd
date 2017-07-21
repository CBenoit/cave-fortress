extends Sprite

export(float,100,1000,10) var reach = 250
export(float,0,2,0.05) var build_lapse = 0.5 # in seconds

var solids_tilemap
var block
var block_pos
var name = "Builder gun"
var picked_tile = 0

var timestamp_last_build = 0

# used to order the tile switch and display a correct preview
var tile_creation_switch = [SolidTiles.TILE_DIRT,SolidTiles.TILE_STONE,SolidTiles.TILE_STEEL]

func _ready():
	solids_tilemap = get_node("../../../solids")
	block = get_node("block")

	set_fixed_process(true)

func _fixed_process(delta):
	var mouse_pos = get_global_mouse_pos()

	block_pos = Vector2(closest_multiple(mouse_pos.x,32),closest_multiple(mouse_pos.y,32)) #in the grid of the tilemap
	block.set_global_pos(block_pos)


	var distance = (mouse_pos - get_global_pos()).length() #distance between the player and placement position
	var block_at_pos = solids_tilemap.get_cellv(solids_tilemap.world_to_map(mouse_pos))

	if (block_at_pos == SolidTiles.TILE_EMPTY and distance < reach):
		block.set_modulate(Color(0,1,0)) #adding a layer of green over the block if it can be placed
	elif (distance < reach):
		block.set_modulate(Color(10,0,0)) # red if within reach but can't place block
	else:
		block.set_modulate(Color(50,50,50)) # grey if out of reach

func create_block():
		if timestamp_last_build + build_lapse * 1000 <= OS.get_ticks_msec() and block.get_modulate() == Color(0,1,0):
			timestamp_last_build = OS.get_ticks_msec()
			#gun_sound.play("zap")
			solids_tilemap.set_cellv(solids_tilemap.world_to_map(block_pos),tile_creation_switch[picked_tile])

func change_picked_tile(step): # step should be either 1 or -1, will be used in the tile switch
	picked_tile = (picked_tile + step) % 3
	block.set_frame([0,1,2][picked_tile]) # because this modulo is crap and  -1% 3 = -1 and not 2

func closest_multiple(x,y): #closest multiple y to x
	return floor(x/y)*y



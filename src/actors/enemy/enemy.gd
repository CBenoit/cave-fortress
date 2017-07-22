extends "../creature.gd"

var hero
var solids

func _ready():
	hero = get_node("../hero")
	solids = get_node("../../solids")

func _pre_fixed_process(delta):
	decide()

func decide():
	set_go_right(get_pos().x < hero.get_pos().x - 30)
	set_go_left(get_pos().x > hero.get_pos().x + 30)

	set_jump(false)
	if go_right or go_left:
		if blocked_on_right() or blocked_on_left():
			if can_jump():
				set_jump(true)
			else:
				dig()

func dig():
	var dig_pos
	if go_right:
		dig_pos = get_pos() + Vector2(SolidTiles.TILE_SIZE, 0)
	elif go_left:
		dig_pos = get_pos() + Vector2(-SolidTiles.TILE_SIZE, 0)
	else:
		dig_pos = get_pos() + Vector2(0, SolidTiles.TILE_SIZE)

	var tile_pos = solids.world_to_map(dig_pos)
	solids.damage_tile(tile_pos, 1)

func can_jump():
	return solids.get_cellv(solids.world_to_map(get_pos() + Vector2(0, -SolidTiles.TILE_SIZE))) == SolidTiles.TILE_EMPTY

func blocked_on_right():
	return solids.get_cellv(solids.world_to_map(get_pos() + Vector2(SolidTiles.TILE_SIZE, 0))) != SolidTiles.TILE_EMPTY

func blocked_on_left():
	return solids.get_cellv(solids.world_to_map(get_pos() + Vector2(-SolidTiles.TILE_SIZE, 0))) != SolidTiles.TILE_EMPTY

func _die():
	queue_free()
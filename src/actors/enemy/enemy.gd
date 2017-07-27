extends "../creature.gd"

const melee_attack_reach = 50
const melee_power = 5
const dig_power = 5
const dig_interval_ms = 350
const attack_interval_ms = 750

# other classes

var Brain = preload("res://ai/decision/brains/DefaultBrain.gd")

# nodes

onready var hero = get_node("../hero")
onready var solids = get_node("../../solids")
onready var anim = get_node("anim")
onready var head = get_node("head")
onready var foots = get_node("foots")

# AI

onready var brain = Brain.new()
var current_action = null
var path_query
var path = []
var current_waypoint_idx = 0

# other

var dig_timestamp = 0
var attack_timestamp = 0

var attack_target
var closest_carrot
var closest_rift
var closest_ally

func _ready():
	hp.connect("on_damage", self, "_handle_damage")

func _pre_fixed_process(delta):
	if current_action != null:
		if not _follow_path():
			current_action.call_func()

func update_ai(astar):
	_update_closest_ally()
	_update_closest_rift()
	_update_closest_carrot()
	_update_goals()
	var action = brain.choose_action()

	if action == Brain.ACTION_ATTACK_CARROT:
		get_node("thought").set_text("Attack carrot!")
		if closest_carrot == null:
			attack_target = hero
			current_action = funcref(self, "_action_attack_player")
		else:
			attack_target = closest_carrot
			current_action = funcref(self, "_action_attack_carrot")
		_init_path_follower(astar, attack_target)
	elif action == Brain.ACTION_ATTACK_PLAYER:
		get_node("thought").set_text("Attack player!")
		attack_target = hero
		current_action = funcref(self, "_action_attack_player")
		_init_path_follower(astar, attack_target)
	elif action == Brain.ACTION_FLEE:
		get_node("thought").set_text("Flee!")
		_init_path_follower(astar, closest_rift)
		current_action = funcref(self, "_action_flee")
	elif action == Brain.ACTION_FOLLOW_ALLIES:
		get_node("thought").set_text("Need allies!")
		current_action = funcref(self, "_action_follow_allies")
	else:
		get_node("thought").set_text("Uh...?")

func _die():
	queue_free()

func _update_goals():
	var destroy_carrot_value = 30 + 10000 / distance_to(closest_carrot)
	brain.set_goal_value(Brain.GOAL_DESTROY_CARROTS, destroy_carrot_value)

	brain.set_goal_value(Brain.GOAL_SURVIVE, 100 * (hp.max_health - hp.health) / hp.max_health)

	var kill_player_goal_value = 13000 / distance_to(hero) + 10 * (hero.hp.max_health - hero.hp.health) / hero.hp.max_health
	brain.set_goal_value(Brain.GOAL_KILL_PLAYER, kill_player_goal_value)

	# TODO: GOAL_FIND_ALLIES

func _take_fall_damage():
	hp.take_damage((velocity.y - MIN_VELOCITY_FALL_DAMAGE) / 10.0)

func _handle_damage(hp):
	anim.play("damage")

func _action_attack_player():
	if can_melee():
		melee_attack_target()
	else:
		_approximate_go_to_pos(attack_target.get_pos())

func _action_attack_carrot():
	if can_melee():
		melee_attack_target()
	else:
		_approximate_go_to_pos(attack_target.get_pos())

func _action_flee():
	_action_attack_player()

func _action_follow_allies():
	var closest_ally = find_closest_ally()
	if closest_ally != null:
		_approximate_go_to_pos(closest_ally)
	else:
		current_action = funcref(self, "_action_flee")

func _process(delta):
	path_query = path_query.resume()
	if typeof(path_query) == TYPE_ARRAY:
		path = path_query
		path_query = null
		set_process(false)

func _init_path_follower(astar, attack_target):
	current_waypoint_idx = 0
	path_query = astar.query_path(
		solids.world_to_map(foots.get_global_pos()),
		solids.world_to_map(attack_target.get_global_pos()),
		2,
		30
	)

	if typeof(path_query) == TYPE_ARRAY:
		path = path_query
	else:
		set_process(true)

func _follow_path():
	if path.empty():
		return false

	if distance_to(attack_target) < 128:
		path.empty()
		return false

	var next_waypoint = solids.map_to_world(path[current_waypoint_idx]) + Vector2(SolidTiles.TILE_SIZE / 2, SolidTiles.TILE_SIZE / 2)
	while get_pos().distance_to(next_waypoint) < 16:
		current_waypoint_idx += 1
		if current_waypoint_idx >= path.size():
			path.clear()
			return false
		next_waypoint = solids.map_to_world(path[current_waypoint_idx]) + Vector2(SolidTiles.TILE_SIZE / 2, SolidTiles.TILE_SIZE / 2)

	set_go_left(false)
	set_go_right(false)
	set_jump(false)

	if foots.get_global_pos().x < next_waypoint.x - 3:
		set_go_right(true)
	elif foots.get_global_pos().x > next_waypoint.x + 3:
		set_go_left(true)

	if foots.get_global_pos().y > next_waypoint.y + 16:
		set_jump(true)

	if solids.get_cellv(path[current_waypoint_idx]) != SolidTiles.TILE_EMPTY:
		dig_at(path[current_waypoint_idx])

	return true

func _approximate_go_to_pos(pos):
	set_go_left(false)
	set_go_right(false)
	if foots.get_global_pos().x < pos.x - 32:
		set_go_right(true)
	elif foots.get_global_pos().x > pos.x + 32:
		set_go_left(true)

	set_jump(false)
	if head.get_global_pos().y < pos.y - 32:
		_approximate_dig()
	elif go_right or go_left:
		if blocked_on_right() or blocked_on_left():
			_approximate_dig()
			if not at_ceiling():
				set_jump(true)
	elif head.get_global_pos().y > pos.y + 64:
		set_jump(true)
		_approximate_dig()

func _approximate_dig():
	var dig_pos = solids.world_to_map(get_pos())
	if go_right:
		dig_pos.x += 1
	elif go_left:
		dig_pos.x -= 1
	elif jump:
		dig_pos.y -= 1
	else:
		dig_pos.y += 1

	dig_at(dig_pos)

func dig_at(tile_pos):
	if dig_timestamp + dig_interval_ms < OS.get_ticks_msec() \
			and get_pos().distance_to(solids.map_to_world(tile_pos)) < melee_attack_reach:
		dig_timestamp = OS.get_ticks_msec()
		solids.damage_tile(tile_pos, dig_power)

func melee_attack_target():
	if attack_timestamp + attack_interval_ms < OS.get_ticks_msec() and can_melee():
		attack_timestamp = OS.get_ticks_msec()

		for grp in attack_target.get_groups():
			if grp == "damageable":
				attack_target.hp.take_damage(melee_power)
			elif grp == "pushable":
				attack_target.push(Vector2(cos(get_pos().angle_to_point(hero.get_pos()) + PI / 2) * 150, -50))

func at_ceiling():
	return solids.get_cellv(solids.world_to_map(head.get_global_pos()) + Vector2(0, -1)) != SolidTiles.TILE_EMPTY

func blocked_on_right():
	return solids.get_cellv(solids.world_to_map(head.get_global_pos()) + Vector2(1, 0)) != SolidTiles.TILE_EMPTY \
			and solids.get_cellv(solids.world_to_map(foots.get_global_pos()) + Vector2(1, 0)) != SolidTiles.TILE_EMPTY

func blocked_on_left():
	return solids.get_cellv(solids.world_to_map(head.get_global_pos()) + Vector2(-1, 0)) != SolidTiles.TILE_EMPTY \
			and solids.get_cellv(solids.world_to_map(foots.get_global_pos()) + Vector2(-1, 0)) != SolidTiles.TILE_EMPTY

func can_melee():
	return distance_to(attack_target) < melee_attack_reach

func distance_to(this):
	return get_pos().distance_to(this.get_pos())

func find_closest_among(entities):
	var closest
	var min_distance = 100000
	for entity in entities:
		var distance = distance_to(entity)
		if distance < min_distance:
			min_distance = distance
			closest = entity
	return closest

func _update_closest_carrot():
	closest_carrot = find_closest_among(get_node("../../carrots").get_children())

func _update_closest_rift():
	closest_rift = find_closest_among(get_node("../../wave").get_children())

func _update_closest_ally():
	pass # TODO

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
onready var close_range = get_node("close_range")

# AI

onready var brain = Brain.new()
var current_action = null

onready var path_target = hero
var last_pathfinding_target = null
var performing_pathfinding = false
var path_query
var path = []
var current_waypoint_idx = 0
var last_pathfinding_timestamp = 0
var waypoint_found_timestamp = 0

var attack_target
var closest_carrot
var closest_rift
var closest_ally

# other

var dig_timestamp = 0
var attack_timestamp = 0

func _ready():
	hp.connect("on_damage", self, "_handle_damage")

# action part

func update_action():
	if current_action != null:
		if not _follow_path():
			current_action.call_func()

func _action_attack_target():
	if can_melee():
		melee_attack_target()
	else:
		_approximate_go_to_pos(attack_target.get_pos())

func _action_flee():
	_approximate_go_to_pos(closest_rift.get_pos())

func _approximate_go_to_pos(pos):
	set_go_left(false)
	set_go_right(false)
	set_jump(false)

	if foots.get_global_pos().x < pos.x - 32:
		set_go_right(true)
	elif foots.get_global_pos().x > pos.x + 32:
		set_go_left(true)

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

	if closest_ally != null:
		_avoid_ally(closest_ally)

var ally_collide_counter = randi()
func _avoid_ally(ally):
	if distance_to(ally) < 46:
		if go_right and ally.get_pos().x > get_pos().x:
			set_go_right(false)
			ally_collide_counter += 1
		elif go_left and ally.get_pos().x < get_pos().x:
			set_go_left(false)
			ally_collide_counter += 1

		if ally_collide_counter % 10 == 0:
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

# AI decision part

func update_decision():
	_update_closest_ally()
	_update_closest_rift()
	_update_closest_carrot()

	_update_goals()

	update_chosen_action(brain.choose_action())

func update_chosen_action(action):
	if action == Brain.ACTION_ATTACK_CARROT:
		if closest_carrot == null:
			update_chosen_action(Brain.ACTION_ATTACK_PLAYER)
			return

		get_node("thought").set_text("Attack carrot!")
		attack_target = closest_carrot
		path_target = attack_target
		current_action = funcref(self, "_action_attack_target")
	elif action == Brain.ACTION_ATTACK_PLAYER:
		get_node("thought").set_text("Attack player!")
		attack_target = hero
		path_target = attack_target
		current_action = funcref(self, "_action_attack_target")
	elif action == Brain.ACTION_FLEE:
		if closest_rift == null or distance_to(hero) < 150:
			update_chosen_action(Brain.ACTION_ATTACK_PLAYER)
			return

		get_node("thought").set_text("Flee!")
		attack_target = hero
		path_target = closest_rift
		current_action = funcref(self, "_action_flee")
	else:
		get_node("thought").set_text("Uh...? " + str(action))

func _update_goals():
	if closest_carrot != null:
		var destroy_carrot_value = 30 + 10000 / distance_to(closest_carrot)
		brain.set_goal_value(Brain.GOAL_DESTROY_CARROTS, destroy_carrot_value)
	else:
		brain.set_goal_value(Brain.GOAL_DESTROY_CARROTS, 0)

	var find_allies_value
	var survive_value = 100 * (hp.max_health - hp.health) / hp.max_health
	if closest_ally == null:
		survive_value += 5
	brain.set_goal_value(Brain.GOAL_SURVIVE, survive_value)

	var kill_player_goal_value = 13000.0 / distance_to(hero) + 10 * (hero.hp.max_health - hero.hp.health) / hero.hp.max_health
	brain.set_goal_value(Brain.GOAL_KILL_PLAYER, kill_player_goal_value)

func _update_closest_carrot():
	if closest_carrot != null:
		closest_carrot.hp.disconnect("killed", self, "_handle_closest_carrot_killed")
	closest_carrot = find_closest_among(get_node("../../carrots").get_children())
	if closest_carrot != null:
		closest_carrot.hp.connect("killed", self, "_handle_closest_carrot_killed")

func _handle_closest_carrot_killed():
	closest_carrot = null

func _update_closest_rift():
	if closest_rift != null:
		closest_rift.hp.disconnect("killed", self, "_handle_closest_rift_killed")
	closest_rift = find_closest_among(get_node("../../wave").get_children())
	if closest_rift != null:
		closest_rift.hp.connect("killed", self, "_handle_closest_rift_killed")

func _handle_closest_rift_killed():
	closest_rift = null

func _update_closest_ally():
	var near_allies = []
	for entity in close_range.get_overlapping_bodies():
		if entity != self and "creature" in entity.get_groups() and entity.team == team:
			near_allies.append(entity)
	if closest_ally != null:
		closest_ally.hp.disconnect("killed", self, "_handle_closest_ally_killed")
	closest_ally = find_closest_among(near_allies)
	if closest_ally != null:
		closest_ally.hp.connect("killed", self, "_handle_closest_ally_killed")

func _handle_closest_ally_killed():
	closest_ally = null

# pathfinding part

func update_path(astar):
	if path.empty() or path_target != last_pathfinding_target \
			or last_pathfinding_timestamp + min(distance_to(path_target) * 10, 10000) < OS.get_ticks_msec():
		last_pathfinding_target = path_target
		last_pathfinding_timestamp = OS.get_ticks_msec()
		path_query = astar.query_path(
			solids.world_to_map(foots.get_global_pos()),
			solids.world_to_map(path_target.get_global_pos()),
			2,
			on_air_time < JUMP_MAX_AIRBORNE_TIME and not jumping,
			60
		)

		if typeof(path_query) == TYPE_ARRAY:
			path = path_query
			_set_current_waypoint_in_path()
		else:
			performing_pathfinding = true

func process_path():
	if performing_pathfinding:
		path_query = path_query.resume()
		if typeof(path_query) == TYPE_ARRAY:
			path = path_query
			_set_current_waypoint_in_path()
			performing_pathfinding = false

func _convert_waypoint(tile_waypoint):
	return solids.map_to_world(tile_waypoint) + Vector2(SolidTiles.TILE_SIZE / 2, SolidTiles.TILE_SIZE / 2)

func _set_current_waypoint_in_path():
	current_waypoint_idx = 0
	var current_waypoint = _convert_waypoint(path[current_waypoint_idx])
	while get_pos().distance_to(current_waypoint) > 16:
		current_waypoint_idx += 1
		if current_waypoint_idx >= path.size():
			path.clear()
			return
		current_waypoint = _convert_waypoint(path[current_waypoint_idx])

func _follow_path():
	if path.empty():
		return false

	if distance_to(attack_target) < melee_attack_reach:
		path.clear()
		return false

	var current_waypoint = _convert_waypoint(path[current_waypoint_idx])
	while (get_pos().distance_to(current_waypoint) < 18 \
			and (not on_ground_tile(current_waypoint) or on_air_time < JUMP_MAX_AIRBORNE_TIME and not jumping)):
		waypoint_found_timestamp = OS.get_ticks_msec()
		current_waypoint_idx += 1
		if current_waypoint_idx >= path.size():
			path.clear()
			return false
		current_waypoint = _convert_waypoint(path[current_waypoint_idx])

	if waypoint_found_timestamp + 3000 < OS.get_ticks_msec():
		path.clear()
		return false

	set_go_right(false)
	set_go_left(false)
	set_jump(false)
	if foots.get_global_pos().x < current_waypoint.x - 4:
		set_go_right(true)
	elif foots.get_global_pos().x > current_waypoint.x + 4:
		set_go_left(true)

	if foots.get_global_pos().y > current_waypoint.y + 16:
		set_jump(true)

	if solids.get_cellv(path[current_waypoint_idx]) != SolidTiles.TILE_EMPTY:
		dig_at(path[current_waypoint_idx])

	#if closest_ally != null:
	#	_avoid_ally(closest_ally)

	return true

# other

func on_ground_tile(pos):
	return solids.get_cellv(solids.world_to_map(pos) + Vector2(0, 1)) != SolidTiles.TILE_EMPTY

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

# creature part

func _take_fall_damage():
	hp.take_damage((velocity.y - MIN_VELOCITY_FALL_DAMAGE) / 10.0)

func _handle_damage(hp):
	anim.play("damage")

func _die():
	queue_free()

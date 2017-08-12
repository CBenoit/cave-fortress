# other classes
var PathNode = preload("PathNode.gd")
var PQ = preload("res://utils/UnorderedMinPQ.gd")

# ============================

var _solids

func _init(solids):
	_solids = solids

# "from" and "to" should be Vector2 representing tilemap position
func query_path(from, to, max_jump_heigth, is_on_ground, max_iter):
	var open_list = PQ.new(funcref(self, "_comparator_less"))
	var closed_list = {}

	var best_candidate
	if is_on_ground:
		best_candidate = PathNode.new(from, null, 0)
	else:
		best_candidate = PathNode.new(from, null, max_jump_heigth * 2)
	best_candidate.current_cost = SolidTiles.PATH_COST[_solids.get_cellv(from)]
	best_candidate.update_cost_evaluation(_heuristic(best_candidate, to))

	open_list.insert(best_candidate)

	var i = 0
	while i < max_iter and not open_list.empty():
		if i % 20 == 0:
			yield()
		i += 1

		var current_candidate = open_list.pop_min()
		var current_pos = current_candidate.tile_pos
		if current_pos == to:
			best_candidate = current_candidate
			break
		closed_list[current_pos] = current_candidate

		for other_pos in [Vector2(current_pos.x + 1, current_pos.y),
						Vector2(current_pos.x - 1, current_pos.y),
						Vector2(current_pos.x, current_pos.y + 1),
						Vector2(current_pos.x, current_pos.y - 1)]:

			# ==== physics rules ====
			if current_candidate.jump_length >= 0 and current_candidate.jump_length % 2 != 0 \
					and current_pos.x != other_pos.x:
				continue

			# if we're falling and successor's height is bigger than ours, skip that successor
			if current_candidate.jump_length >= max_jump_heigth * 2 and current_pos.y > other_pos.y:
				continue

			var new_jump_length
			if _at_ceiling(other_pos) and not _on_ground(other_pos):
				new_jump_length = max(max_jump_heigth * 2, current_candidate.jump_length + 1);
			elif other_pos.y < current_pos.y:
				if current_candidate.jump_length % 2 == 0:
					new_jump_length = current_candidate.jump_length + 2
				else:
					new_jump_length = current_candidate.jump_length + 1
			elif _on_ground(other_pos):
				new_jump_length = 0
			elif other_pos.y > current_pos.y:
				if current_candidate.jump_length % 2 == 0:
					new_jump_length = max(max_jump_heigth * 2, current_candidate.jump_length + 2)
				else:
					new_jump_length = max(max_jump_heigth * 2, current_candidate.jump_length + 1)
			else: # not on ground and not same x posision
        		new_jump_length = current_candidate.jump_length + 1

			if new_jump_length >= max_jump_heigth * 4 \
					and other_pos.x != current_pos.x \
					and (new_jump_length - (max_jump_heigth * 4)) % 8 != 3:
				continue
			# ==== end physics rules ====

			var other_node = PathNode.new(other_pos, current_candidate, new_jump_length)
			other_node.update_cost(SolidTiles.PATH_COST[_solids.get_cellv(other_pos)])
			other_node.update_cost_evaluation(_heuristic(other_node, to))
			if not closed_list.has(other_pos) or other_node.jump_length < closed_list[other_pos].jump_length:
				open_list.insert(other_node)
				best_candidate = get_best_of(other_node, best_candidate, to)

	var path = [best_candidate.tile_pos]
	var current = best_candidate
	while current.parent != null:
		var prev = current
		current = current.parent
		if _solids.get_cellv(current.tile_pos) != SolidTiles.TILE_EMPTY:
			path.push_front(current.tile_pos)
			continue

		if current.parent == null: # starting node
			path.push_front(current.tile_pos)
			break

		if (current.parent.jump_length != 0 and current.jump_length == 0) \
				or (current.jump_length == 2 and current.parent.jump_length != 0) \
				or (current.jump_length == 0 and prev.jump_length != 0) \
				or (current.jump_length == max_jump_heigth * 2):
			path.push_front(current.tile_pos)

	return path

func get_best_of(this, that, target):
	if _heuristic(this, target) < _heuristic(that, target):
		return this
	else:
		return that

func _comparator_less(this_node, that_node):
	return this_node.total_cost_evaluation < that_node.total_cost_evaluation

func _heuristic(node, target):
	return node.jump_length / 4.0 + 2 * (abs(node.tile_pos.x - target.x) + abs(node.tile_pos.y - target.y))

func _on_ground(tile_pos):
	return _solids.get_cell(tile_pos.x, tile_pos.y + 1) != SolidTiles.TILE_EMPTY

func _at_ceiling(tile_pos):
	return _solids.get_cell(tile_pos.x, tile_pos.y - 1) != SolidTiles.TILE_EMPTY

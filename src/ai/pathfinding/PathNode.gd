var parent
var tile_pos
var jump_length
var current_cost
var total_cost_evaluation

func _init(tile_pos, parent, jump_length):
	self.tile_pos = tile_pos
	self.parent = parent
	self.jump_length = jump_length

func update_cost(tile_cost):
	current_cost = parent.current_cost + tile_cost

func update_cost_evaluation(heuristic_value):
	total_cost_evaluation = current_cost + heuristic_value

func equal_to(other):
	return tile_pos == other.tile_pos and jump_length == other.jump_length

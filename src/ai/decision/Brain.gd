# other classes

var Action = preload("Action.gd")
var Goal = preload("Goal.gd")

# attributes

var _goals = {}
var _actions = {}

# goal functions

func add_goal(goal_id, goal_discontentment_exponent):
	# get discontentment_exponent from parameters
	_goals[goal_id] = Goal.new(goal_discontentment_exponent)

func set_goal_value(goal_id, value):
	_goals[goal_id].value = value

func get_goal_value(goal_id):
	return _goals[goal_id].value

func increase_goal_value(goal_id, value):
	_goals[goal_id].value += value

func decrease_goal_value(goal_id, value):
	_goals[goal_id].value -= value

# action functions

func add_action(action_id, goals_changes):
	# construct action from parameters
	var action = Action.new()
	action.set_all_goal_changes(goals_changes)

	# add it
	_actions[action_id] = action

# returns an action id
func choose_action():
	# Go through each action and select the one that
	# reduce the most discontentment.
	var best_action_id = null
	var best_value = 100000 # a high value which is very bad

	for action_id in _actions.keys():
		var this_value = _calculate_discontentment(_actions[action_id])
		if this_value < best_value:
			best_value = this_value
			best_action_id = action_id

	return best_action_id

func _calculate_discontentment(action):
	var discontentment = 0
	for goal_id in _goals.keys():
		# fetch the goal
		var goal = _goals[goal_id]
		# calculate the new goal value after action
		var new_value = goal.value + action.get_goal_change(goal_id)
		# get the discontentment for this goal
		discontentment += goal.get_discontentment(new_value)

	return discontentment

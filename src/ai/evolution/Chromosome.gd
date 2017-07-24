var fitness = 0
var _goals_discontentment_exponents = {}
var _actions_goals_changes = {}

func update_brain(brain):
	for goal_id in get_all_goal_ids():
		brain.add_goal(goal_id, get_goal_discontentment_exponent(goal_id))

	for action_id in get_all_action_ids():
		brain.add_action(action_id, get_action_goals_changes(action_id))

func add_goal_discontentment_exponent(goal_id, value):
	_goals_discontentment_exponents[goal_id] = value

func get_goal_discontentment_exponent(goal_id):
	if _goals_discontentment_exponents.has(goal_id):
		return _goals_discontentment_exponents[goal_id]

	return 0

func get_all_goal_ids():
	return _goals_discontentment_exponents.keys()

func add_action_goal_change(action_id, goal_id, value):
	if not _actions_goals_changes.has(action_id):
		_actions_goals_changes[action_id] = {}

	_actions_goals_changes[action_id][goal_id] = value

func get_action_goals_changes(action_id):
	if not _actions_goals_changes.has(action_id):
		return {}

	return _actions_goals_changes[action_id]

func get_all_action_ids():
	return _actions_goals_changes.keys()

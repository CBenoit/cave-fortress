var _goal_changes = {}

func set_goal_change(goal_id, change_value):
	_goal_changes[goal_id] = change_value

func erase_goal_change(goal_id):
	_goal_changes.erase(goal_id)

func set_all_goal_changes(goal_changes):
	_goal_changes.clear()
	for key in goal_changes.keys():
		_goal_changes[key] = goal_changes[key]

func get_goal_change(goal_id):
	if _goal_changes.has(goal_id):
		return _goal_changes[goal_id]
	else:
		return 0

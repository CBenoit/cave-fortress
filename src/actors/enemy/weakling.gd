extends "enemy.gd"

# other classes

var Brain = preload("res://ai/decision/brains/DefaultBrain.gd")

# AI

onready var brain = Brain.new()

# AI decision part

func update_decision():
	.update_decision() # call to parent's update_decision

	_update_goals()

	_update_chosen_action(brain.choose_action())

func _update_chosen_action(action):
	if action == Brain.ACTION_ATTACK_CARROT:
		if closest_carrot == null:
			_update_chosen_action(Brain.ACTION_ATTACK_PLAYER)
			return

		attack_target = closest_carrot
		path_target = attack_target
		current_action = funcref(self, "_action_attack_target")
	elif action == Brain.ACTION_ATTACK_PLAYER:
		attack_target = hero
		path_target = attack_target
		current_action = funcref(self, "_action_attack_target")
	elif action == Brain.ACTION_FLEE:
		if closest_rift == null or distance_to(hero) < 150:
			_update_chosen_action(Brain.ACTION_ATTACK_PLAYER)
			return

		attack_target = hero
		path_target = closest_rift
		current_action = funcref(self, "_action_flee")
	else:
		print("Unexpected action ", action)

func _update_goals():
	if closest_carrot != null:
		var destroy_carrot_value = 30 + 10000 / distance_to(closest_carrot)
		brain.set_goal_value(Brain.GOAL_DESTROY_CARROTS, destroy_carrot_value)
	else:
		brain.set_goal_value(Brain.GOAL_DESTROY_CARROTS, 0)

	var survive_value = 100 * (hp.max_health - hp.health) / hp.max_health \
		- (OS.get_ticks_msec() - spawned_timestamp) / 2000
	if closest_ally == null:
		survive_value += 5
	brain.set_goal_value(Brain.GOAL_SURVIVE, survive_value)

	var kill_player_goal_value = 13000.0 / distance_to(hero) + 10 * (hero.hp.max_health - hero.hp.health) / hero.hp.max_health
	brain.set_goal_value(Brain.GOAL_KILL_PLAYER, kill_player_goal_value)

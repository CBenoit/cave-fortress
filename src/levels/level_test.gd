extends "./abstract_level.gd"



func _launch_wave():
	if current_wave == 0:
		wave.available_mole = [
			5 # ENEMY
		]
		wave.initiate_mole_count()
		wave.evaluate_reward()

		wave.add_rift(Vector2(-550,-200))
		wave.add_rift(Vector2(1200,-400))

		wave.add_garrison_to_rift(0,ENEMY,3)
		wave.add_garrison_to_rift(1,ENEMY,2)
		wave.spawn_from_rift(0,ENEMY,3)
		wave.spawn_from_rift(1,ENEMY,2)
	else:
		wave.available_mole = [
			5 # ENEMY
		]
		wave.initiate_mole_count()
		wave.evaluate_reward()

		wave.add_garrison_to_rift(0,ENEMY,3)
		wave.add_garrison_to_rift(1,ENEMY,2)
		wave.spawn_from_rift(0,ENEMY,3)
		wave.spawn_from_rift(1,ENEMY,2)


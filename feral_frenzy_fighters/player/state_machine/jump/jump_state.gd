class_name JumpState
extends State


func update(_delta):
	if character.frame > 0:
		return Globals.States.AIR
	character.velocity.y = character.jump_speed
	var direction = Input.get_axis(
		character.get_input("left"), character.get_input("right")
	)
	if direction: # jumping applies some amount of horizontal speed
		if character.velocity.x >= 0:
			if character.velocity.x * direction < 0:  # vel and direction are opposite
				character.velocity.x += direction * get_accel()
			character.velocity.x = maxf(character.velocity.x, direction * get_speed()) # cap velocity but conserve momentum
		else:
			if character.velocity.x * direction < 0:  # vel and direction are opposite
				character.velocity.x += direction * get_accel()
			character.velocity.x = minf(character.velocity.x, direction * get_speed()) # cap velocity but conserve momentum
			
	return get_state()


func get_accel():
	pass


func get_speed():
	pass


func get_state():
	pass

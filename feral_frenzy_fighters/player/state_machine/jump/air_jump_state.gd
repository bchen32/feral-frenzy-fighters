class_name AirJumpState
extends JumpState


func exit():
	# Jump carries momentum
	if character.velocity.x >= 0:
		character.air_speed_upper_bound = maxf(character.velocity.x, character.air_jump_speed)
		character.air_speed_lower_bound = -character.air_jump_speed
	else:
		character.air_speed_lower_bound = minf(character.velocity.x, -character.air_jump_speed)
		character.air_speed_upper_bound = character.air_jump_speed


func update(delta):
	return super(delta)


func get_state():
	return Globals.States.AIR_JUMP


func get_accel():
	return character.air_jump_accel


func get_speed():
	return character.air_jump_speed

class_name GroundMoveState
extends State


func update(delta):
	play_audio()
	if InputManager.is_action_pressed(character.get_input("jump")):
		return get_jump_state()
	if not character.is_on_floor():
		return Globals.States.AIR
	if InputManager.is_action_just_pressed(character.get_input("attack")):
		return get_attack_state()
	var direction = InputManager.get_axis(
		character.get_input("left"), character.get_input("right")
	)
	
	if direction:
		character.anim_player.flip_h = direction > 0
		if character.velocity.x * direction < 0:  # vel and direction are opposite
			character.velocity.x = move_toward(character.velocity.x, 0.0, get_accel() * delta)
		else:
			if abs(character.velocity.x) < get_speed():
				character.velocity.x += direction * get_accel() * delta
			# Soft clamp for when character is knocked back and sliding
			if character.velocity.x > get_speed():
				character.velocity.x = move_toward(character.velocity.x, get_speed(), get_accel() * delta)
			elif character.velocity.x < -get_speed():
				character.velocity.x = move_toward(character.velocity.x, -get_speed(), get_accel() * delta)
	else:  # nothing held down
		character.velocity.x = move_toward(character.velocity.x, 0.0, get_accel() * delta)
		if character.velocity.x == 0:
			return Globals.States.IDLE
	return get_state()


func play_audio():
	pass


func get_state():
	pass


func get_jump_state():
	pass


func get_attack_state():
	pass


func get_accel():
	pass


func get_speed():
	pass

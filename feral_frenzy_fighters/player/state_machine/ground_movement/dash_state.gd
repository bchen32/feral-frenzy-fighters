class_name DashState
extends GroundMoveState


func enter():
	character.play_anim("dash")
	await Globals.get_tree().create_timer(0.01).timeout #this is a ridiculous workaround
	character.play_particles(
		character.dash_particles,
		0,
		45,
		int(25), #Lmfao vvvvvvv
		character.position + Vector2(character.CS.get_shape().get_rect().size.x/2 * sign(character.velocity.x), character.CS.get_shape().get_rect().size.y/2 ),
		-Vector3(1*sign(character.velocity.x),1,0),
		Vector2(50,200))


func exit():
	character.air_speed_upper_bound = character.get_scaled_stat("dash_speed")
	character.air_speed_lower_bound = -character.get_scaled_stat("dash_speed")


func update(delta):
	if not InputManager.is_action_pressed(character.get_input("dash")) && abs(InputManager.get_axis(character.get_input("left"), character.get_input("right"))) < .1:
		return Globals.States.WALK
	return super(delta)


func play_audio():
	if character.frame % 10 == 0:
		character.play_audio(PlayerCharacter.AudioType.DASH)


func get_state():
	return Globals.States.DASH


func get_jump_state():
	return Globals.States.DASH_JUMP


func get_attack_state():
	return Globals.States.DASH_ATTACK


func get_accel():
	return character.stats.dash_accel


func get_speed():
	return character.get_scaled_stat("dash_speed")

class_name JumpState
extends State


func enter():
	character.play_anim("jump")
	character.play_audio(character.AudioType.JUMP)
	character.jumps_left -= 1
	
	var char_vel = character.velocity.y #Another insane (mentally) workaround to get Y vel when jump was started.
	await Globals.get_tree().create_timer(0.01).timeout
	
	if abs(char_vel) < .01:
		character.play_particles(
		character.dash_particles,
		0,
		45,
		int(20 + int(abs(character.velocity.x/20))), #Lmfao vvvvvvv
		character.position + Vector2(character.CS.get_shape().get_rect().size.x/2 * sign(character.velocity.x), character.CS.get_shape().get_rect().size.y/2 ),
		-Vector3(1*sign(character.velocity.x),-1,0),
		Vector2(50,200))
	else:
		character.play_particles(
		character.dash_particles,
		0,
		45,
		int(20), #Lmfao vvvvvvv
		character.position + Vector2(character.CS.get_shape().get_rect().size.x/2 * sign(character.velocity.x), character.CS.get_shape().get_rect().size.y/2 ),
		-Vector3(1*sign(character.velocity.x),-1,0),
		Vector2(200,200))
		


func update(_delta):
	if character.frame > 0:
		return Globals.States.AIR
	character.velocity.y = character.jump_speed
	var direction = InputManager.get_axis(
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

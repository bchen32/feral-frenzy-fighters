class_name GroundMoveState
extends State

var particle_timer = 0

func update(delta):
	play_audio()	
	
	if particle_timer <= 0:
		character.play_particles(
			character.dash_particles,
			0,
			45,
			int(1), #Lmfao vvvvvvv
			character.position + Vector2(character.CS.get_shape().get_rect().size.x/2 * sign(character.velocity.x), character.CS.get_shape().get_rect().size.y/2 ),
			-Vector3(1*sign(character.velocity.x),1,0),
			Vector2(50,200))
		particle_timer = .1/(character.velocity.x)
	else:
		particle_timer-=delta
		
	if Input.is_action_pressed(character.get_input("jump")):
		return get_jump_state()
	if not character.is_on_floor():
		return Globals.States.AIR
	if Input.is_action_just_pressed(character.get_input("attack")):
		return get_attack_state()
	var direction = Input.get_axis(
		character.get_input("left"), character.get_input("right")
	)
	if direction:
		character.anim_player.flip_h = direction > 0
		if character.velocity.x * direction < 0:  # vel and direction are opposite
			deccel(delta)
		else:
			character.velocity.x += direction * get_accel() * delta
			character.velocity.x = clamp(character.velocity.x, -get_speed(), get_speed())
	else:  # nothing held down
		deccel(delta)
		if character.velocity.x == 0:
			return Globals.States.IDLE
	return get_state()


func deccel(delta):
	if character.velocity.x > 0:
		character.velocity.x -= get_accel() * delta
		character.velocity.x = maxf(character.velocity.x, 0.0)
	else:
		character.velocity.x += get_accel() * delta
		character.velocity.x = minf(character.velocity.x, 0.0)


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

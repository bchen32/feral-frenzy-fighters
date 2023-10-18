class_name HitState
extends State

var hitstun: int


func enter():
	character.play_anim("hit")
	
	if not NetworkManager.is_host and not NetworkManager.is_connected:
		character.blood_splatter(180)
	hitstun = floor(character.kb * character.kb_hitstun_scale)
	character.velocity.x = cos(character.kb_angle) * character.kb
	character.velocity.y = sin(character.kb_angle) * character.kb
	if character.velocity.y > 0: # Make spikes less punishing
		character.velocity.y *= character.spike_mult
	character.hit = false


func exit():
	if character.velocity.x >= 0:
		character.air_speed_upper_bound = character.velocity.x
		character.air_speed_lower_bound = -character.air_jump_speed
	else:
		character.air_speed_lower_bound = character.velocity.x
		character.air_speed_upper_bound = character.air_jump_speed
	character.kb = 0.0
	character.kb_angle = 0.0
	hitstun = 0


func update(delta):
	if character.frame >= hitstun:
		if character.is_on_floor():
			return Globals.States.IDLE
		return Globals.States.AIR
	var collision = character.move_and_collide(character.velocity * delta, true)
	if collision:
		var norm = collision.get_normal()
		if character.velocity.project(norm).length() > character.bounce_thresh:
			character.velocity = character.velocity.bounce(norm) * character.bounce_decay
			hitstun = floor(hitstun * character.bounce_decay)
			character.kb_angle = atan2(character.velocity.y, character.velocity.x)
			if character.velocity.y > 0: # Make spikes less punishing
				character.velocity.y *= character.spike_mult
	if character.velocity.x > 0:
		character.velocity.x -= character.kb_decay * cos(character.kb_angle) * delta
		character.velocity.x = maxf(character.velocity.x, 0.0)
	elif character.velocity.x < 0:
		character.velocity.x -= character.kb_decay * cos(character.kb_angle) * delta
		character.velocity.x = minf(character.velocity.x, 0.0)
	character.velocity.y += character.hit_grav * delta
	character.velocity.y = minf(character.velocity.y, character.terminal_vel)
	return Globals.States.HIT

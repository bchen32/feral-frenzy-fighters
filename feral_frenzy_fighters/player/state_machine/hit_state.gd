class_name HitState
extends State

var hitstun: int


func enter():
	character.play_anim("hit")
	
	character.play_particles(
	character.physics_blood,
	0,
	180,
	10 * character.percentage)

	character.play_particles(
	character.physics_blood,
	1,
	180,
	10)
	
	hitstun = floor(character.kb * character.stats.kb_hitstun_scale)
	character.velocity.x = cos(character.kb_angle) * character.kb
	character.velocity.y = sin(character.kb_angle) * character.kb
	if character.velocity.y > 0: # Make spikes less punishing
		character.velocity.y *= character.stats.spike_mult
	character.hit = false
	


func exit():
	if character.velocity.x >= 0:
		character.air_speed_upper_bound = character.velocity.x
		character.air_speed_lower_bound = -character.get_scaled_stat("air_jump_speed")
	else:
		character.air_speed_lower_bound = character.velocity.x
		character.air_speed_upper_bound = character.get_scaled_stat("air_jump_speed")
	character.kb = 0.0
	character.kb_angle = 0.0
	hitstun = 0
	character.play_anim("fall") # in case player is hit into air, otherwise this'll get overriden


func update(delta):
	if character.frame >= hitstun:
		if character.is_on_floor():
			return Globals.States.IDLE
		return Globals.States.AIR
	var collision = character.move_and_collide(character.velocity * delta, true)
	if collision:
		var norm = collision.get_normal()
		if character.velocity.project(norm).length() > character.stats.bounce_thresh:
			character.velocity = character.velocity.bounce(norm) * character.stats.bounce_decay
			hitstun = floor(hitstun * character.stats.bounce_decay)
			character.kb_angle = atan2(character.velocity.y, character.velocity.x)
			if character.velocity.y > 0: # Make spikes less punishing
				character.velocity.y *= character.stats.spike_mult
	if character.velocity.x > 0:
		character.velocity.x -= character.stats.kb_decay * cos(character.kb_angle) * delta
		character.velocity.x = maxf(character.velocity.x, 0.0)
	elif character.velocity.x < 0:
		character.velocity.x -= character.stats.kb_decay * cos(character.kb_angle) * delta
		character.velocity.x = minf(character.velocity.x, 0.0)
	character.velocity.y += character.stats.hit_grav * delta
	character.velocity.y = minf(character.velocity.y, character.stats.terminal_vel)
	return Globals.States.HIT

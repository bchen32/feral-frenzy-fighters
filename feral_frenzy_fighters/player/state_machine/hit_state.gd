class_name HitState
extends State

var hitstun: int


func enter():
	character.play_anim("hit")
	hitstun = floor(character.kb * character.kb_hitstun_scale)
	character.velocity.x = cos(character.kb_angle) * character.kb
	character.velocity.y = sin(character.kb_angle) * character.kb
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
	if character.velocity.x > 0:
		character.velocity.x -= character.kb_decay * cos(character.kb_angle) * delta
		character.velocity.x = maxf(character.velocity.x, 0.0)
	else:
		character.velocity.x += character.kb_decay * cos(character.kb_angle) * delta
		character.velocity.x = minf(character.velocity.x, 0.0)
	# Only decay vertical velocity if it's up
	if character.velocity.y < 0:
		character.velocity.y += character.kb_decay * sin(character.kb_angle) * delta
		character.velocity.y = minf(character.velocity.y, 0.0)
	return Globals.States.HIT

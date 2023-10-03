class_name GroundAttackState
extends AttackState


func enter():
	super()
	direction = "neutral"
	attack = character.attacks[direction]
	character.play_anim("attack_%s" % direction)


func update(delta):
	if character.frame >= attack.frames:
		return Globals.States.IDLE
	if character.velocity.x > 0:
		character.velocity.x -= character.tilt_attack_accel * delta
		character.velocity.x = maxf(character.velocity.x, 0.0)
	else:
		character.velocity.x += character.tilt_attack_accel * delta
		character.velocity.x = minf(character.velocity.x, 0.0)
	character.update_attack(direction)
	return Globals.States.GROUND_ATTACK

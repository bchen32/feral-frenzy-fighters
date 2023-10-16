class_name AirAttackState
extends AttackState


func enter():
	super()
	attack = character.attacks["air_" + direction]
	character.play_anim("air_attack_%s" % direction)


func update(delta):
	if character.frame >= attack.frames or character.is_on_floor():
		return Globals.States.IDLE
	character.velocity.y += character.get_grav() * delta
	character.velocity.y = minf(character.velocity.y, character.terminal_vel)
	character.update_attack("air_" + direction)
	return Globals.States.AIR_ATTACK

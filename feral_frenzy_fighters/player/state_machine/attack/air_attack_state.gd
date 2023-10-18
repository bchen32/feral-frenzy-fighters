class_name AirAttackState
extends AttackState


func enter():
	super()
	direction = "neutral"
	attack = character.attacks["air_" + direction]
	character.chosen_attack = attack
	character.play_anim("air_attack_%s" % direction)


func update(delta):
	if character.frame >= character.chosen_attack.frames or character.is_on_floor():
		return Globals.States.IDLE
	character.air_movement(delta)
	character.update_attack("air_" + direction)
	return Globals.States.AIR_ATTACK

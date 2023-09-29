class_name GroundAttackState
extends AttackState


func enter():
	super()
	attack = character.attacks[direction]
	character.play_anim("attack_%s" % direction)
	character.velocity.x = 0.0


func update(_delta):
	if character.frame >= attack.frames:
		return Globals.States.IDLE
	character.update_attack(direction)
	return Globals.States.GROUND_ATTACK

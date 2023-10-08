class_name GroundAttackState
extends AttackState


func enter():
	super()
	var attacks = character.attacks
	
	character.chosen_attack = attacks[direction]
	attack = character.chosen_attack
	character.play_anim("attack_%s" % direction)
	character.velocity.x = 0.0


func update(_delta):
	var chosen_attack = character.attacks[direction]
	
	if character.frame >= character.chosen_attack["frames"]:
		return Globals.States.IDLE
	character.update_attack(direction)
	return Globals.States.GROUND_ATTACK

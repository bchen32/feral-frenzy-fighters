class_name DashAttackState
extends AttackState


func enter():
	super()
	if character.velocity.x > 0:
		character.velocity.x = character.dash_attack_speed
	elif character.velocity.x < 0:
		character.velocity.x = -character.dash_attack_speed
	else:
		if direction == "left":
			character.velocity.x = -character.dash_attack_speed
		elif direction == "right":
			character.velocity.x = character.dash_attack_speed
	attack = character.attacks["dash_attack"]
	character.play_anim("dash_attack")


func update(delta):
	#print(character.velocity.x)
	if character.frame >= attack.frames:
		return Globals.States.IDLE
	if not character.is_on_floor():
		return Globals.States.AIR
	if character.velocity.x > 0:
		character.velocity.x -= character.dash_attack_accel * delta
		character.velocity.x = maxf(character.velocity.x, 0.0)
	else:
		character.velocity.x += character.dash_attack_accel * delta
		character.velocity.x = minf(character.velocity.x, 0.0)
	character.update_attack("dash_attack")
	return Globals.States.DASH_ATTACK

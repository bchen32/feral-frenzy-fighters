class_name BeanbagIdleState
extends State


func enter():
	character.play_anim("idle")


func update(delta):
	if not character.is_on_floor():
		return Globals.States.AIR
	character.velocity.x = move_toward(character.velocity.x, 0.0, character.stats.walk_accel * delta)
	return Globals.States.IDLE

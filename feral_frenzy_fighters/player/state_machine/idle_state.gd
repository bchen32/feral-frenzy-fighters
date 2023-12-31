class_name IdleState
extends State


func enter():
	character.play_anim("idle")


func exit():
	character.air_speed_upper_bound = character.get_scaled_stat("walk_speed")
	character.air_speed_lower_bound = -character.get_scaled_stat("walk_speed")


func update(_delta):
	if not character.is_on_floor():
		return Globals.States.AIR
	if InputManager.is_action_pressed(character.get_input("jump")):
		return Globals.States.WALK_JUMP
	if InputManager.is_action_just_pressed(character.get_input("attack")):
		return Globals.States.GROUND_ATTACK
	var direction = InputManager.get_axis(
		character.get_input("left"), character.get_input("right")
	)
	if direction or character.velocity.x != 0.0:
		return Globals.States.WALK
	return Globals.States.IDLE

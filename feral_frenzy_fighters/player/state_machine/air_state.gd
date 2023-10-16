class_name AirState
extends State

var play_anim: bool


func enter():
	play_anim = true


func exit():
	character.air_speed_upper_bound = character.walk_speed
	character.air_speed_lower_bound = -character.walk_speed


func update(delta):
	if character.is_on_floor():
		character.jumps_left = 1
		return Globals.States.IDLE
	elif InputManager.is_action_just_pressed(character.get_input("jump")) and character.jumps_left > 0:
		character.jumps_left -= 1
		return Globals.States.AIR_JUMP
	elif InputManager.is_action_pressed(character.get_input(("attack"))):
		return Globals.States.AIR_ATTACK
	else:
		if character.velocity.y > 0 and play_anim:	
			character.play_anim("fall")
			play_anim = false
		character.velocity.y += character.get_grav() * delta
		character.velocity.y = minf(character.velocity.y, character.terminal_vel)
		var direction = InputManager.get_axis(
			character.get_input("left"), character.get_input("right")
		)
		if direction:
			character.velocity.x += direction * character.air_accel * delta
			character.velocity.x = clamp(character.velocity.x, character.air_speed_lower_bound, character.air_speed_upper_bound)
		return Globals.States.AIR

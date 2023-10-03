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
		character.jumps_left = 2
		return Globals.States.IDLE
	elif Input.is_action_just_pressed(character.get_input("jump")) and character.jumps_left > 0:
		character.jumps_left -= 1
		return Globals.States.AIR_JUMP
	elif Input.is_action_pressed(character.get_input(("attack"))):
		return Globals.States.AIR_ATTACK
	else:
		if character.velocity.y > 0 and play_anim:	
			character.play_anim("fall")
			play_anim = false
		character.air_movement(delta)
		return Globals.States.AIR

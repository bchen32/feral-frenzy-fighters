class_name DashJumpState
extends JumpState


func enter():
	character.play_anim("jump")
	character.play_audio(character.AudioType.JUMP)

func exit():
	character.air_speed_upper_bound = character.dash_speed
	character.air_speed_lower_bound = -character.dash_speed


func update(delta):
	return super(delta)

func get_state():
	return Globals.States.DASH_JUMP


func get_accel():
	return character.dash_jump_accel


func get_speed():
	return character.dash_speed

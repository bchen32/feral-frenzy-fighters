class_name WalkJumpState
extends JumpState


func enter():
	character.play_anim("jump")
	character.play_audio(character.AudioType.JUMP)


func exit():
	character.air_speed_upper_bound = character.walk_speed
	character.air_speed_lower_bound = -character.walk_speed


func update(delta):
	return super(delta)


func get_state():
	return Globals.States.WALK_JUMP


func get_accel():
	return character.walk_jump_accel


func get_speed():
	return character.walk_speed

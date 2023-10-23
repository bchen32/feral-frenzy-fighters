class_name DashJumpState
extends JumpState


func exit():
	character.air_speed_upper_bound = character.stats.dash_speed
	character.air_speed_lower_bound = -character.stats.dash_speed


func update(delta):
	return super(delta)

func get_state():
	return Globals.States.DASH_JUMP


func get_accel():
	return character.stats.dash_jump_accel


func get_speed():
	return character.stats.dash_speed

class_name DashState
extends GroundMoveState


func enter():
	character.play_anim("dash")


func exit():
	character.air_speed_upper_bound = character.stats.dash_speed
	character.air_speed_lower_bound = -character.stats.dash_speed


func update(delta):
	if not Input.is_action_pressed(character.get_input("dash")):
		return Globals.States.WALK
	return super(delta)


func play_audio():
	if character.frame % 10 == 0:
		character.play_audio(PlayerCharacter.AudioType.DASH)


func get_state():
	return Globals.States.DASH


func get_jump_state():
	return Globals.States.DASH_JUMP


func get_attack_state():
	return Globals.States.DASH_ATTACK


func get_accel():
	return character.stats.dash_accel


func get_speed():
	return character.stats.dash_speed

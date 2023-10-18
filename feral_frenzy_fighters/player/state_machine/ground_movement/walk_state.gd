class_name WalkState
extends GroundMoveState


func enter():
	character.play_anim("walk")


func exit():
	character.air_speed_upper_bound = character.stats.walk_speed
	character.air_speed_lower_bound = -character.stats.walk_speed


func update(delta):
	if Input.is_action_pressed(character.get_input("dash")):
		return Globals.States.DASH
	return super(delta)


func play_audio():
	if character.frame % 20 == 0:
		character.play_audio(PlayerCharacter.AudioType.WALK)


func get_state():
	return Globals.States.WALK


func get_jump_state():
	return Globals.States.WALK_JUMP


func get_attack_state():
	return Globals.States.GROUND_ATTACK


func get_accel():
	return character.stats.walk_accel


func get_speed():
	return character.stats.walk_speed

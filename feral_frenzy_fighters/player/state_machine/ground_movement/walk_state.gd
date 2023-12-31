class_name WalkState
extends GroundMoveState

var stick_change = 0
var flick_dash = false

func enter():
	character.play_anim("walk")
	await Globals.get_tree().create_timer(0.01).timeout #this is a ridiculous workaround
	character.play_particles(
		character.dash_particles,
		0,
		45,
		int(10), #Lmfao vvvvvvv
		character.position + Vector2(character.CS.get_shape().get_rect().size.x/2 * sign(character.velocity.x), character.CS.get_shape().get_rect().size.y/2 ),
		-Vector3(1*sign(character.velocity.x),1,0),
		Vector2(50,200))

func exit():
	character.air_speed_upper_bound = character.get_scaled_stat("walk_speed")
	character.air_speed_lower_bound = -character.get_scaled_stat("walk_speed")


func update(delta):
	
	if character.gamepad == true:
		var direction = InputManager.get_axis(character.get_input("left"), character.get_input("right"))
		var last_stick = stick_change
	
		stick_change = direction
	
		if abs(last_stick - stick_change) > .50:
			flick_dash = true
			
		if InputManager.is_action_pressed(character.get_input("dash")) || flick_dash == true:
			flick_dash = false
			return Globals.States.DASH
				
	else:
		if InputManager.is_action_pressed(character.get_input("dash")):
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
	return character.get_scaled_stat("walk_speed")

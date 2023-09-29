class_name AttackState
extends State

var direction: String
var attack: Dictionary = {}


func enter():
	var left_right = Input.get_axis(
		character.get_input("left"), character.get_input("right")
	)
	var up_down = Input.get_axis(
		character.get_input("up"), character.get_input("down")
	)
	# Note: the ordering of these if statements implicitly defines the priority of attacks
	# when multiple directions are held down at the same time
	if left_right > 0:
		direction = "left"
	elif left_right < 0:
		direction = "right"
	elif up_down > 0:
		direction = "up"
	elif up_down < 0:
		direction = "down"
	else:
		direction = "neutral"
	direction = "neutral"  # just for game jam since only neutral is implemented
	character.play_audio(character.AudioType.ATTACK)


func exit():
	character.air_speed_upper_bound = character.walk_speed
	character.air_speed_lower_bound = -character.walk_speed
	direction = ""
	attack = {}
	character.end_attack()  # in case attack got interrupted by hit

extends Node

# player id -> list of input dicts (Dictionary[Array[Dictionary]]
var past_input_sent_queue: Dictionary = {}

var _current_input_sent: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func switch_player_id(player_id: int):
	if player_id not in past_input_sent_queue or past_input_sent_queue[player_id].is_empty():
		_current_input_sent = {}
	else:
		_current_input_sent = past_input_sent_queue[player_id].pop_front()

func get_axis(negative_input: String, positive_input: String) -> float:
	if negative_input.is_empty():
		return false
	
	return Input.get_axis(negative_input, positive_input)

func is_action_just_pressed(input: String):
	if input.is_empty():
		return false
	
	return Input.is_action_just_pressed(input)

func is_action_pressed(input: String) -> bool:
	if input.is_empty():
		return false
	
	return Input.is_action_pressed(input)


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
	var host_input_name: String = "axis_%s_%s" % [negative_input, positive_input]
	
	if NetworkManager.is_host and host_input_name in _current_input_sent:
		return _current_input_sent[host_input_name]
	elif NetworkManager.is_connected or NetworkManager.is_host or NetworkManager.ggpo_multiplayer != null:
		return 0
	else:
		return Input.get_axis(negative_input, positive_input)

func is_action_just_pressed(input: String):
	if NetworkManager.is_host and "just_press_actions" in _current_input_sent and \
	   input in _current_input_sent["just_press_actions"]:
		return true
	elif NetworkManager.is_connected or NetworkManager.is_host  or NetworkManager.ggpo_multiplayer != null:
		return false
	else:
		return Input.is_action_just_pressed(input)

func is_action_pressed(input: String) -> bool:
	if NetworkManager.is_host and "press_actions" in _current_input_sent and \
	   input in _current_input_sent["press_actions"]:
		return true
	elif NetworkManager.is_connected or NetworkManager.is_host or NetworkManager.ggpo_multiplayer != null:
		return false
	else:
		return Input.is_action_pressed(input)

func get_input_actions(character: PlayerCharacter) -> Dictionary:
	var actions: Dictionary = {}
	var actions_to_check: Array[String] = ["dash", "jump", "attack", "down"]
	
	for action_to_check in actions_to_check:
		var player_input_name: String = character.get_input(action_to_check)
		
		if Input.is_action_pressed(player_input_name):
			if Input.is_action_just_pressed(player_input_name):
				if "just_press_actions" in actions:
					actions["just_press_actions"].push_back(action_to_check)
				else:
					actions["just_press_actions"] = [action_to_check]
			
			if "press_actions" in actions:
				actions["press_actions"].push_back(action_to_check)
			else:
				actions["press_actions"] = [action_to_check]
	
	var left_right_axis: float = Input.get_axis(character.get_input("left"), character.get_input("right"))
	var up_down_axis: float = Input.get_axis(character.get_input("up"), character.get_input("down"))
	
	if left_right_axis != 0:
		actions["axis_left_right"] = left_right_axis
	
	if up_down_axis != 0:
		actions["axis_up_down"] = up_down_axis
	
	return actions

extends Node

enum States { AIR, AIR_ATTACK, AIR_JUMP, DASH, DASH_ATTACK, DASH_JUMP, GROUND_ATTACK, HIT, IDLE, WALK, WALK_JUMP }

var cutscene_player_video_path: String = "res://gui/menus/cutscenes/intro_cutscene.ogv"
var cutscene_player_end_game: bool = false
var player1_won: bool = false
var player_sprites: Array[String] = ["cat", "cat"]
var stage: int

var audio_stream_to_play_during_cutscene: AudioStream
var sfx_val = -1
var music_val = -1

var p1_inputs = []
var p2_inputs = []

var p1_gamepad = []
var p2_gamepad = []

var player_gamepad = {
	0 : false,
	1 : false
}

signal shake_completed
var passwords = {}

class menu:
	var _queue = []
	
	func _init(item):
		_queue.append(item)
		self._queue = _queue
		#print("starting with", item)
	
	func next(item):
		_queue.back().hide()
		_queue.append(item)
		item.show()
		if item != null:
			focus_button(item)
		#print("appending", item)
	
	func back():
		#print("popping", _queue.back())
		if len(_queue) > 1:
			_queue.pop_back().hide()
			_queue.back().show()
			focus_button(_queue.back())
		
	func focus_button(item):
		for node in item.get_tree().get_nodes_in_group("TitleButtons"):
			if node.is_visible_in_tree():
				node.grab_focus()
				return 

func _ready():
	
	for action in InputMap.get_actions():
		if "p1" in action:
			p1_inputs.append(InputMap.action_get_events(action))

	for x in len(p1_inputs):
		for y in len(p1_inputs[x]):
			if "Joypad" in p1_inputs[x][y]:
				p1_gamepad.append(p1_inputs[x][y])

	for action in InputMap.get_actions():
		if "p2" in action:
			p2_inputs.append(InputMap.action_get_events(action))

	for x in len(p2_inputs):
		for y in len(p2_inputs[x]):
			if "Joypad" in p2_inputs[x][y]:
				p2_gamepad.append(p2_inputs[x][y])


func setup_controls():
	for stuff in Input.get_connected_joypads():
		print(Input.get_joy_name(stuff))
		print(Input.get_joy_guid(stuff))
	
	if len(Input.get_connected_joypads()) <= 0:
		player_gamepad[0] = false
		player_gamepad[1] = false
	elif len(Input.get_connected_joypads()) >= 2:
		rebind_p1(0)
		rebind_p2(1)
		player_gamepad[0] = true
		player_gamepad[1] = true
	else:
		rebind_p1(10) # Removes Joypad control from p1 (10 is an arbitrary number)
		rebind_p2(0) # Makes the sole controller player p2
		player_gamepad[0] = false
		player_gamepad[1] = true
		
		
		

func rebind_p1(device_number: int):
	for event in p1_gamepad:
		event.set_device(device_number)

func rebind_p2(device_number: int):
	for event in p2_gamepad:
		event.set_device(device_number)
		
func shake(node, amount: float = 5, duration: float = .01, count: int = 10, password = 0, player = false):
	if node:
		passwords[node] = password
		print("first ", passwords[node])
		var og_pos = node.global_position
		for i in count:
				randomize()
				var tween := create_tween()
				tween.tween_property(
				node, 
				"global_position", 
				Vector2(randf_range(node.global_position.x + -amount,node.global_position.x + amount), randf_range(node.global_position.y + -amount, node.global_position.y + amount)), 
				duration)
				await get_tree().create_timer(duration).timeout
				amount/=1.2
				
		if player == true:
			if passwords[node] == password:
				node.global_position = og_pos
				print("last ", passwords[node])
				emit_signal("shake_completed", passwords[node])
		else:
			node.global_position = og_pos






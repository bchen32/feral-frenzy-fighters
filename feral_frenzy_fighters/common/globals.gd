extends Node

enum States { AIR, AIR_ATTACK, AIR_JUMP, DASH, DASH_ATTACK, DASH_JUMP, GROUND_ATTACK, HIT, IDLE, WALK, WALK_JUMP }

var cutscene_player_video_path: String = "res://gui/menus/cutscenes/intro_cutscene.ogv"
var cutscene_player_end_game: bool = false
var player1_won: bool = false
var player_sprites: Array[PackedScene] = []

var audio_stream_to_play_during_cutscene: AudioStream
var sfx_val = -1
var music_val = -1

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




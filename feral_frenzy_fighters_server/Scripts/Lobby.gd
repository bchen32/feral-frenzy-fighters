extends Node

class_name Lobby

enum NetworkGameState {
	NOT_CONNECTED,
	LOBBY,
	CHARACTER_SELECT,
	STAGE_SELECT,
	INFIRSTCUTSCENE,
	INBATTLE,
	INSECONDCUTSCENE
}

enum ChatEmoji {
	THUMBS_UP,
	THUMBS_DOWN,
	SKULL
}

const TARGET_PLAYERS = 2
const START_STOCK = 5
const START_PERCENTAGE = 0

var selected_stage: int = -1

var _lobby_game_state: NetworkGameState = NetworkGameState.LOBBY
var _players: Dictionary = {}
var _network_manager: NetworkManager
var _ready_to_battle: Dictionary = {}
var _env_data: Dictionary = {}

func _init(network_manager: NetworkManager):
	_network_manager = network_manager

func is_lobby_available():
	return len(_players) < TARGET_PLAYERS

func is_lobby_dead():
	return _players.is_empty()

func get_lobby_state_string(lobby_num: int):
	var lobby_state = "L%s:\n" % lobby_num
	
	for player_id in _players:
		var player = _players[player_id]
		lobby_state += "  %s-%s\n" % [player.player_id, player.display_name] 
	
	return lobby_state 


func add_player(player_id: int):
	_players[player_id] = Player.new(len(_players), player_id)
	
	if len(_players) >= TARGET_PLAYERS:
		_lobby_game_state = NetworkGameState.CHARACTER_SELECT
		
		var display_names: Array[String] = []
	
		for player_key in _players:
			var player = _players[player_key]
			display_names.append(player.display_name)
	
		# setup game state while they are in the cutscene
		for player_key in _players:
			var player = _players[player_key]
			
			player.stock = START_STOCK
			player.percentage = START_PERCENTAGE
		
			# set level spawn poses
			match player.player_num:
				0:
					player.position = Vector2(464, 247)
				1:
					player.position = Vector2(880, 247)
			
			_network_manager.initial_game_information.rpc_id(player.player_id, 
															 player.player_num,
															 display_names,
															 START_STOCK,
															 START_PERCENTAGE)
		
		_network_manager.game_state_change.rpc(_lobby_game_state, "")
	else:
		_network_manager.game_state_change.rpc_id(player_id, _lobby_game_state, 
												  _players[player_id].display_name)

func get_player():
	pass

func remove_player(player_id: int):
	_players.erase(player_id)
	
	if _lobby_game_state != NetworkGameState.LOBBY:
		_lobby_game_state = NetworkGameState.LOBBY
		for player_key in _players:
			_network_manager.game_state_change.rpc_id(player_key, NetworkGameState.LOBBY, "")

func game_state_change_request(sender_id: int, requested_game_state: Lobby.NetworkGameState):
	if (_lobby_game_state == NetworkGameState.INFIRSTCUTSCENE and requested_game_state == NetworkGameState.INBATTLE) or \
	   (_lobby_game_state == NetworkGameState.STAGE_SELECT and requested_game_state == NetworkGameState.INFIRSTCUTSCENE):
		_ready_to_battle[sender_id] = true
		
		if len(_ready_to_battle) == len(_players):
			_lobby_game_state = requested_game_state
			
			for player_key in _players:
				_network_manager.game_state_change.rpc_id(player_key, _lobby_game_state, "")
			
			_ready_to_battle = {}

func get_env_data(sender_id: int, env_name: String):
	if env_name not in _env_data:
		_env_data[env_name] = {sender_id: true}
	else:
		_env_data[env_name][sender_id] = true
	
	if len(_env_data[env_name]) >= len(_players):
		var env_data: Array = []
		
		_env_data[env_name] = {}
		
		match env_name:
			"plasma_ball":
				for i in range(5):
					var rand_x = randi_range(0, 1920)
					var rand_y = randi_range(0, 1080)
					
					if i != 0:
						while env_data[i - 1].distance_to(Vector2(rand_x, rand_y)) < 1000:
							rand_x = randi_range(0, 1920)
							rand_y = randi_range(0, 1080)
					
					env_data.push_back(Vector2(rand_x, rand_y))
				
				env_data.push_back(Vector2(1539, 629))
			"event":
				var random_event: int = 0 if selected_stage == 2 else randi_range(0, 1)
				
				env_data.push_back(random_event)
				
				if selected_stage == 0:
					if random_event == 1:
						# hairball on cat tree level
						env_data.push_back(randi_range(0, 1)) # hairball position
						env_data.push_back(randi_range(0, 5)) # hairball shooting delay
						env_data.push_back(randf_range(-60, 0)) # hairball angle
					else:
						# falling mouse on cat tree level
						env_data.push_back(randi_range(500, 1500))
						env_data.push_back(randf_range(-.3, .3))
						env_data.push_back(randf_range(0,.3))
				else:
					# fish net and gravel cleaner on fish tank level, and chompy on turtle habitat level
					env_data.push_back(randi_range(0, 1))
					
					if selected_stage == 2:
						# chompy
						env_data.push_back(randi_range(5, 10))
			"water_level":
				env_data.push_back(randi_range(20, 30))
			"snapping_manager":
				var turtle_amount = 4
				var x_spawn_points = [-200, 2200]
				
				for t in turtle_amount:
					var turtle_positions = [Vector2(x_spawn_points.pick_random(), randi_range(560, 920))]
					
					for i in range(10):
						turtle_positions.push_back(Vector2(randi_range(0, 1920), randi_range(450, 990)))
					
					env_data.push_back(turtle_positions)
			"sprouting_cycle":
				var sprouting_cycle = [0, 1, 2, 3, 4, 5, 6]
				
				while not sprouting_cycle.is_empty():
					var sprouting = sprouting_cycle.pick_random()
					sprouting_cycle.erase(sprouting)
					
					env_data.push_back(randi_range(3, 7))
					env_data.push_back(sprouting)
		
		for player_key in _players:
			print("send env data %s for %s" % [player_key, env_name])
			_network_manager.send_env_data.rpc_id(player_key, env_name, env_data)
		
		_env_data[env_name] = {}

func change_game_state(game_state: Lobby.NetworkGameState):
	if _lobby_game_state != game_state:
		_lobby_game_state = game_state
		
		for player_key in _players:
			_network_manager.game_state_change.rpc_id(player_key, _lobby_game_state, "")

func update_game_information(sender_id: int, player_position: Vector2, player_state_type: Player.StateType,
							 flip_h: bool):
	_players[sender_id].position = player_position
	_players[sender_id].player_state_type = player_state_type
	_players[sender_id].flip_h = flip_h

func update():
	var player_datas: Dictionary = {}
	
	for player_key in _players:
		var player = _players[player_key]
		var player_data: Dictionary = {
			"percentage": player.percentage,
			"stock": player.stock,
			"position": player.position,
			"state": player.player_state_type,
			"flip_h": player.flip_h
		}
		
		player_datas[player.player_num] = player_data
	
	for player_key in _players:
		_network_manager.game_information.rpc_id(player_key, player_datas)

func death_on_player(player_num: int):
	for player_key in _players:
		var dead_player = _players[player_key]
		
		if dead_player.player_num == player_num:
			dead_player.stock -= 1
			dead_player.percentage = 0
			
			if dead_player.stock <= 0:
				for player_key_to_send in _players:
					_lobby_game_state = NetworkGameState.INSECONDCUTSCENE
					print("dead: %s" % dead_player.player_num)
					
					_network_manager.game_state_change.rpc_id(player_key_to_send, _lobby_game_state, 
															  "%s" % dead_player.player_num)

func hit_on_player(player_num: int, hit_data: Dictionary):
	for player_key in _players:
		var player = _players[player_key]
		
		if player.player_num == player_num:
			player.percentage += hit_data["dmg"]

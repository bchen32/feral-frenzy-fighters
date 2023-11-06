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

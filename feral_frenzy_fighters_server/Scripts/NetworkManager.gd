extends Control

class_name NetworkManager

const NETWORK_PORT = 11111

var _web_socket_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()

var _death_reports: Dictionary = {}
var _lobbies = []
var _players_in_which_lobbies: Dictionary = {}

func log_to_server_log(message: String):
	var log_text = "%s\n" % message
	
	print(log_text)
	$ServerLogBackground/RichTextLabel.add_text(log_text)


func _init():
	_web_socket_peer.supported_protocols = ["ludus"]
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self._peer_disconnected)
	
	var web_address = "ws://%s:%s" % ["127.0.0.1",~ NETWORK_PORT]
	
	_web_socket_peer.create_server(NETWORK_PORT)
	multiplayer.multiplayer_peer = _web_socket_peer
	
	log_to_server_log("Server initialized at port %s" % NETWORK_PORT)

func _peer_connected(id):
	log_to_server_log("Peer %s joined" % id)
	
	var lobby_found: bool = false
	
	for lobby in _lobbies:
		if lobby.is_lobby_available():
			_players_in_which_lobbies[id] = lobby
			
			lobby.add_player(id)
			lobby_found = true
			break
	
	if not lobby_found:
		_lobbies.append(Lobby.new(self))
		
		_lobbies[len(_lobbies) - 1].add_player(id)
		_players_in_which_lobbies[id] = _lobbies[len(_lobbies) - 1]

func _peer_disconnected(id):
	log_to_server_log("Peer %s left" % id)
	
	assert(id in _players_in_which_lobbies)
	
	_players_in_which_lobbies[id].remove_player(id)
	
	if _players_in_which_lobbies[id].is_lobby_dead():
		_lobbies.erase(_players_in_which_lobbies[id])
	
	_players_in_which_lobbies.erase(id)
	print("erased")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var lobbies_text: String = ""
	
	for i in range(len(_lobbies)):
		lobbies_text += _lobbies[i].get_lobby_state_string(i)
		
		_lobbies[i].update()
	
	$LobbiesBackground/ContentLabel.text = lobbies_text

@rpc("any_peer", "reliable", "call_remote")
func update_game_information(player_position: Vector2, player_state: Player.StateType, 
							 flip_h: bool):
	# later we should do state replication on this stuff to prevent cheating, 
	# but for now accepting the updates as is is fine
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id in _players_in_which_lobbies:
		_players_in_which_lobbies[sender_id].update_game_information(sender_id, player_position,
																	 player_state, flip_h)

@rpc("any_peer", "reliable", "call_remote")
func game_state_change_request(requested_game_state: Lobby.NetworkGameState):
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id in _players_in_which_lobbies:
		_players_in_which_lobbies[sender_id].game_state_change_request(sender_id,
																	   requested_game_state)

@rpc("any_peer", "reliable", "call_remote")
func report_death(player_num: int):
	var sender_id = multiplayer.get_remote_sender_id()
	var lobby = _players_in_which_lobbies[sender_id]
	
	if lobby not in _death_reports:
		_death_reports[lobby] = {}
	
	if player_num not in _death_reports[lobby]:
		_death_reports[lobby][player_num] = [sender_id]
	elif sender_id not in _death_reports[lobby][player_num]:
		_death_reports[lobby][player_num].append(sender_id)
	
	if _death_reports[lobby][player_num].size() >= 2:
		lobby.death_on_player(player_num)
		
		ack_death.rpc(player_num)
		
		_death_reports[lobby].erase(player_num)

@rpc("any_peer", "reliable", "call_remote")
func report_chat(emoji: Lobby.ChatEmoji):
	var sender_id = multiplayer.get_remote_sender_id()
	var lobby = _players_in_which_lobbies[sender_id]
	var chatty_player_num = lobby._players[sender_id].player_num
	
	for player_key in lobby._players:
		ack_chat.rpc_id(player_key, chatty_player_num, emoji) 

@rpc("any_peer", "reliable", "call_remote")
func report_hit(player_num: int, hit_data: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	var lobby = _players_in_which_lobbies[sender_id]
	
	lobby.hit_on_player(player_num, hit_data)
	
	for player_key in lobby._players:
		ack_hit.rpc_id(player_key, player_num, hit_data)

@rpc("any_peer", "reliable", "call_remote")
func report_env_hit(env_part: String, health_change: float):
	var sender_id = multiplayer.get_remote_sender_id()
	var lobby = _players_in_which_lobbies[sender_id]
	
	for player_key in lobby._players:
		ack_env_hit.rpc_id(player_key, env_part, health_change)

@rpc("any_peer", "reliable", "call_remote")
func character_stage_screen_character_change(character_stage: int):
	var sender_id = multiplayer.get_remote_sender_id()
	var lobby = _players_in_which_lobbies[sender_id]
	var is_character_select_screen: bool = \
		lobby._lobby_game_state == Lobby.NetworkGameState.CHARACTER_SELECT
	
	if is_character_select_screen or lobby._lobby_game_state == Lobby.NetworkGameState.STAGE_SELECT:
		var player_num: int = -1
		
		for player_key in lobby._players:
			if player_key == sender_id:
				player_num = lobby._players[player_key].player_num
				
				if (is_character_select_screen and lobby._players[player_key].character_locked_in) or \
				   (not is_character_select_screen and lobby._players[player_key].stage_locked_in):
					return
				elif is_character_select_screen:
					lobby._players[player_key].character_type = clampi(character_stage, 0, 2) 
				else:
					lobby._players[player_key].stage_type = clampi(character_stage, 0, 2)
		
		assert(player_num >= 0)
		
		for player_key in lobby._players:
			ack_character_screen_character_change.rpc_id(player_key, player_num, character_stage)

@rpc("any_peer", "reliable", "call_remote")
func character_stage_screen_lock_in():
	var sender_id = multiplayer.get_remote_sender_id()
	var lobby = _players_in_which_lobbies[sender_id]
	var is_character_select_screen: bool = \
		lobby._lobby_game_state == Lobby.NetworkGameState.CHARACTER_SELECT
	
	if is_character_select_screen or lobby._lobby_game_state == Lobby.NetworkGameState.STAGE_SELECT:
		var player_num: int = -1
		var locked_in_char_type: int = -1
		
		for player_key in lobby._players:
			if player_key == sender_id:
				player_num = lobby._players[player_key].player_num
				
				if (is_character_select_screen and lobby._players[player_key].character_locked_in) or \
				   (not is_character_select_screen and lobby._players[player_key].stage_locked_in):
					return
				elif is_character_select_screen:
					lobby._players[player_key].character_locked_in = true
					locked_in_char_type = lobby._players[player_key].character_type
				else:
					lobby._players[player_key].stage_locked_in = true
					locked_in_char_type = lobby._players[player_key].character_type
				
				break
		
		assert(player_num >= 0)
		
		var all_players_locked_in: bool = true
		
		for player_key in lobby._players:
			if (is_character_select_screen and not lobby._players[player_key].character_locked_in) or \
			   (not is_character_select_screen and not lobby._players[player_key].stage_locked_in):
				all_players_locked_in = false
			
			ack_character_stage_screen_lock_in.rpc_id(player_key, player_num, locked_in_char_type)
		
		
		if all_players_locked_in:
			var player_stage
			
			if not is_character_select_screen:
				player_stage = randi_range(0, lobby._players.size() - 1)
				player_stage = lobby._players.values()[player_stage].stage_type
			
			for player_key in lobby._players:
				if is_character_select_screen:
					lobby.change_game_state(Lobby.NetworkGameState.STAGE_SELECT)
				else:
					lobby.selected_stage = player_stage
					stage_selected.rpc_id(player_key, player_stage)

# rpcs called on the client
@rpc("authority", "reliable", "call_remote")
func initial_game_information(player_num: int, display_names: Array, 
							  initial_stock: int, initial_percentage: int):
	pass

@rpc("authority", "reliable", "call_remote")
func game_information(player_datas: Dictionary):
	pass

@rpc("authority", "reliable", "call_remote")
func game_state_change(game_state: Lobby.NetworkGameState, display_name: String):
	pass
	
@rpc("authority", "reliable", "call_remote")
func ack_death(player_num: int):
	pass

@rpc("authority", "reliable", "call_remote")
func ack_hit(player_num: int):
	pass

@rpc("authority", "reliable", "call_remote")
func ack_chat(player_num: int, emoji: Lobby.ChatEmoji):
	pass

@rpc("authority", "reliable", "call_remote")
func ack_env_hit(env_part: String, health_change: float):
	pass

@rpc("authority", "reliable", "call_remote")
func ack_character_screen_character_change(player_num: int, character: int):
	pass

@rpc("authority", "reliable", "call_remote")
func ack_character_stage_screen_lock_in(player_num: int, character_stage: int):
	pass

@rpc("authority", "reliable", "call_remote")
func stage_selected(stage_selected: int):
	pass

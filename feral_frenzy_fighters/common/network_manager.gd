extends Node

var multiplayer_peer = ENetMultiplayerPeer.new()

const SERVER_IP = "192.168.184.136"
const SERVER_PORT = 11111
const SERVER_BUILD = true

signal network_game_state_changed
signal recieved_player_data
signal death_acked
signal hit_acked
signal chat_acked

enum NetworkGameState {
	NOT_CONNECTED,
	LOBBY,
	IN_FIRST_CUTSCENE,
	IN_BATTLE,
	IN_SECOND_CUTSCENE
}

enum ChatEmoji {
	THUMBS_UP,
	THUMBS_DOWN,
	SKULL
}

var display_names: Array
var damage_label
var my_player_num: int
var initial_stock: int
var initial_percentage: int
var is_connected: bool = false
var is_host: bool = false

var _death_reports: Dictionary = {}
var _lobbies = []
var _network_game_state: NetworkGameState = NetworkGameState.NOT_CONNECTED
var _players_in_which_lobbies: Dictionary = {}

func log_to_server_log(message: String):
	var log_text = "%s\n" % message
	
	print(log_text)
	#$ServerLogBackground/RichTextLabel.add_text(log_text)

func get_current_network_game_state() -> NetworkGameState:
	return _network_game_state

func _init():
	#multiplayer_peer.supported_protocols = ["fff_network"]
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connection_failed.connect(self._disconnected)
	multiplayer.connected_to_server.connect(self._connected)

func become_host():
	if not SERVER_BUILD:
		return
	
	for i in range(0, 2):
		Globals.player_sprites.append("cat")
	
	Globals.stage = 0
	
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self._peer_disconnected)
	
	#var web_address = "ws://%s:%s" % ["127.0.0.1", SERVER_PORT]
	
	multiplayer_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	#multiplayer_peer.set_bind_ip(SERVER_IP)
	
	is_host = true
	
	log_to_server_log("Server initialized at port %s" % SERVER_PORT)

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
		_lobbies.append(ServerLobby.new(self))
		
		add_child(_lobbies.back())
		#_lobbies.back().hide()
		
		_lobbies[len(_lobbies) - 1].add_player(id)
		_players_in_which_lobbies[id] = _lobbies[len(_lobbies) - 1]

func _peer_disconnected(id):
	log_to_server_log("Peer %s left" % id)
	
	assert(id in _players_in_which_lobbies)
	
	_players_in_which_lobbies[id].remove_player(id)
	
	if _players_in_which_lobbies[id].is_lobby_dead():
		var dead_lobby = _players_in_which_lobbies[id]
		
		_lobbies.erase(dead_lobby)
		
		dead_lobby.queue_free()
	
	_players_in_which_lobbies.erase(id)
	print("erased")

func establish_connection():
	if not is_host:
		multiplayer.multiplayer_peer = null
		#var server_address = "ws://" + SERVER_IP + ":" + str(SERVER_PORT)
		
		for i in range(0, 2):
			Globals.player_sprites.append("cat")
		
		Globals.stage = 0
		
		multiplayer_peer.create_client(SERVER_IP, SERVER_PORT)
		multiplayer.multiplayer_peer = multiplayer_peer

func _disconnected():
	multiplayer.multiplayer_peer = null
	is_connected = false
	print("Disconnected from server/connection failed")

func _connected():
	print("Connected to server")
	is_connected = true

func disconnect_network():
	assert(multiplayer_peer == multiplayer.multiplayer_peer)
	
	multiplayer_peer.close()
	_disconnected()

@rpc("authority", "reliable", "call_remote")
func game_state_change(game_state: NetworkGameState, display_name: String):
	display_names = [display_name]
	_network_game_state = game_state
	
	network_game_state_changed.emit(game_state)
	
	match game_state:
		NetworkManager.NetworkGameState.LOBBY:
			get_tree().change_scene_to_file("res://levels/lobby.tscn")
		NetworkManager.NetworkGameState.IN_FIRST_CUTSCENE:
			Globals.cutscene_player_end_game = false
			Globals.cutscene_player_video_path = ""
			Globals.audio_stream_to_play_during_cutscene = null
			get_tree().change_scene_to_file("res://gui/menus/cutscene_player.tscn")
		NetworkManager.NetworkGameState.IN_SECOND_CUTSCENE:
			Globals.cutscene_player_end_game = true
			
			if display_name == "0":
				Globals.cutscene_player_video_path = "res://gui/menus/cutscenes/cat_v_cat_player_two_wins.ogv"
			else:
				assert(display_name == "1")
				Globals.cutscene_player_video_path = "res://gui/menus/cutscenes/cat_v_cat_player_one_wins.ogv"
			
			
			Globals.audio_stream_to_play_during_cutscene = preload("res://gui/menus/music/triumphant.wav")
			get_tree().change_scene_to_file("res://gui/menus/cutscene_player.tscn")
		_:
			pass

@rpc("authority", "reliable", "call_remote")
func initial_game_information(player_num: int, display_names: Array, 
							  initial_stock: int, initial_percentage: int):
	self.display_names = display_names
	self.my_player_num = player_num
	self.initial_stock = initial_stock
	self.initial_percentage = initial_percentage

@rpc("authority", "unreliable", "call_remote")
func game_information(player_datas: Dictionary):
	recieved_player_data.emit(player_datas)

@rpc("authority", "reliable", "call_remote")
func ack_death(player_num: int):
	death_acked.emit(player_num)

@rpc("authority", "reliable", "call_remote")
func ack_hit(player_num: int, hit_data: Dictionary):
	hit_acked.emit(player_num, hit_data)

@rpc("authority", "reliable", "call_remote")
func ack_chat(player_num: int, chat_emoji: ChatEmoji):
	chat_acked.emit(player_num, chat_emoji)

@rpc("authority", "reliable", "call_remote")
func update_damage_label(player_num: int, percentage: int, stock: int):
	if damage_label != null:
		damage_label.set_player_damage(player_num, percentage)
		damage_label.set_player_death_count(player_num, stock)

@rpc("any_peer", "reliable", "call_remote")
func player_input(input_action: String):
	# later we should do state replication on this stuff to prevent cheating, 
	# but for now accepting the updates as is is fine
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id in _players_in_which_lobbies:
		_players_in_which_lobbies[sender_id].player_input(input_action)

@rpc("any_peer", "reliable", "call_remote")
func send_network_input(input: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id in _players_in_which_lobbies:
		if sender_id in InputManager.past_input_sent_queue:
			InputManager.past_input_sent_queue[sender_id].push_back(input)
		else:
			InputManager.past_input_sent_queue[sender_id] = [input]

@rpc("any_peer", "reliable", "call_remote")
func game_state_change_request(requested_game_state: NetworkManager.NetworkGameState):
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id in _players_in_which_lobbies:
		_players_in_which_lobbies[sender_id].game_state_change_request(sender_id,
																	   requested_game_state)

@rpc("any_peer", "reliable", "call_remote")
func report_chat(emoji: NetworkManager.ChatEmoji):
	if NetworkManager.is_host:
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

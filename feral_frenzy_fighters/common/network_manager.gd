extends Node

var multiplayer_peer = WebSocketMultiplayerPeer.new()

const SERVER_IP = "127.0.0.1"#"feral.insightgit.com"
const SERVER_PORT = 11111

signal network_game_state_changed
signal recieved_player_data
signal death_acked
signal hit_acked
signal chat_acked
signal env_hit_acked
signal character_stage_screen_change_acked
signal character_stage_screen_lock_in_acked
signal on_stage_selected

enum NetworkGameState {
	NOT_CONNECTED,
	LOBBY,
	CHARACTER_SELECT,
	STAGE_SELECT,
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
var my_player_num: int
var initial_stock: int
var initial_percentage: int
var is_connected: bool = false

var _network_game_state: NetworkGameState = NetworkGameState.NOT_CONNECTED

func get_current_network_game_state() -> NetworkGameState:
	return _network_game_state

func _init():
	multiplayer_peer.supported_protocols = ["ludus"]
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connection_failed.connect(self._disconnected)
	multiplayer.connected_to_server.connect(self._connected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func establish_connection():
	multiplayer.multiplayer_peer = null
	var server_address = "ws://" + SERVER_IP + ":" + str(SERVER_PORT)
	
	multiplayer_peer.create_client(server_address)
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
		NetworkManager.NetworkGameState.CHARACTER_SELECT:
			get_tree().change_scene_to_file("res://gui/menus/character_select.tscn")
		NetworkManager.NetworkGameState.STAGE_SELECT:
			$"../CharacterSelect".on_locked_in()
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
func ack_env_hit(env_part: String, health_change: float):
	env_hit_acked.emit(env_part, health_change)

@rpc("authority", "reliable", "call_remote")
func ack_character_stage_screen_character_change(player_num: int, character: int):
	character_stage_screen_change_acked.emit(player_num, character)

@rpc("authority", "reliable", "call_remote")
func ack_character_stage_screen_lock_in(player_num: int):
	character_stage_screen_lock_in_acked.emit(player_num)

@rpc("authority", "reliable", "call_remote")
func stage_selected(stage_selected: int):
	on_stage_selected.emit(stage_selected)

# Code execed on server
@rpc("any_peer", "unreliable", "call_remote")
func update_game_information(player_position: Vector2, player_state: Globals.States, flip_h: bool):
	pass

@rpc("any_peer", "reliable", "call_remote")
func character_stage_screen_lock_in():
	pass

@rpc("any_peer", "reliable", "call_remote")
func report_death(player_num: int):
	pass

@rpc("any_peer", "reliable", "call_remote")
func game_state_change_request(requested_game_state: NetworkGameState):
	pass

@rpc("any_peer", "reliable", "call_remote")
func report_hit(player_num: int, hit_data: Dictionary):
	pass

@rpc("any_peer", "reliable", "call_remote")
func report_env_hit(env_part: String, health_change: float):
	pass

@rpc("any_peer", "reliable", "call_remote")
func character_stage_screen_character_change(character: int):
	pass

@rpc("any_peer", "reliable", "call_remote")
func report_chat(emoji: ChatEmoji):
	pass

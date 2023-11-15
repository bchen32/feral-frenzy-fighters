extends Control

@export var node_to_show: CanvasItem
@export var audio_stream_player: AudioStreamPlayer

@export var audio_stream_to_play_during: AudioStream
@export var audio_stream_to_play_after: AudioStream

var wait_till_network: bool = false
var _was_network_action: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var video_stream = VideoStreamTheora.new()
	video_stream.file = Globals.cutscene_player_video_path
	
	if Globals.cutscene_player_video_path == "":
		_on_video_stream_player_finished()
	else:
		$VideoStreamPlayer.stream = video_stream
		$VideoStreamPlayer.play()
		
		if audio_stream_to_play_during == null:
			audio_stream_to_play_during = Globals.audio_stream_to_play_during_cutscene
		
		if audio_stream_player != null and audio_stream_to_play_during != null:
			audio_stream_player.stream = audio_stream_to_play_during
			audio_stream_player.play()
	
	wait_till_network = NetworkManager.is_connected
	
	if wait_till_network:
		NetworkManager.network_game_state_changed.connect(_on_network_game_state_changed)

func _on_network_game_state_changed(game_state: NetworkManager.NetworkGameState):
	_was_network_action = true
	_on_video_stream_player_finished()
	_was_network_action = false

func _input(event: InputEvent) :
	if event.is_action_pressed("video_skip") and Globals.cutscene_player_video_path != "":
		_on_video_stream_player_finished()

func _on_video_stream_player_finished():
	%VideoStreamPlayer.hide()
	$skip_controller.hide()
	$skip_keyboard.hide()
	
	await get_tree().create_timer(.01).timeout
	if wait_till_network and Globals.cutscene_player_end_game:
		NetworkManager.disconnect_network()
		
		wait_till_network = false
	
	if wait_till_network and not _was_network_action:
		if audio_stream_player != null:
			audio_stream_player.stop()
		
		var next_requested_game_state: NetworkManager.NetworkGameState
		
		match NetworkManager.get_current_network_game_state():
			NetworkManager.NetworkGameState.IN_FIRST_CUTSCENE:
				next_requested_game_state = NetworkManager.NetworkGameState.IN_BATTLE
			NetworkManager.NetworkGameState.IN_SECOND_CUTSCENE:
				next_requested_game_state = NetworkManager.NetworkGameState.IN_FIRST_CUTSCENE
		
		$VideoStreamPlayer.stop()
		NetworkManager.game_state_change_request.rpc(next_requested_game_state)
		
		return
	
	Globals.audio_stream_to_play_during_cutscene = null
	Globals.cutscene_player_video_path = ""
	
	if node_to_show != null:
		hide()
		node_to_show.show()
		
		if audio_stream_player != null:
			audio_stream_player.stop()
			
			if audio_stream_to_play_after != null:
				audio_stream_player.stream = audio_stream_to_play_after
				audio_stream_player.play()
	elif Globals.cutscene_player_end_game:
		Globals.cutscene_player_video_path = "res://gui/menus/cutscenes/intro_cutscene.ogv"
		get_tree().change_scene_to_file("res://gui/menus/title_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://levels/main.tscn")



func _on_skip_keyboard_ready():
	get_node("skip_keyboard").play("Skip_Keyboard")


func _on_skip_controller_ready():
	get_node("skip_controller").play("Skip_Controller")


func _on_skip_keyboard_animation_looped():
	await get_tree().create_timer(5).timeout
	get_node("skip_keyboard").hide()
	get_node("skip_controller").hide()




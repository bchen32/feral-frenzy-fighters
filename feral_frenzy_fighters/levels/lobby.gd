extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if NetworkManager.is_connected:
		$Player.player_num = 0
		$Player.player_id = NetworkManager.multiplayer_peer.get_unique_id()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

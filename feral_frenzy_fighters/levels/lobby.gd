extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.ggpo_multiplayer = GGPOMultiplayer.new()
	
	NetworkManager.ggpo_multiplayer.nodes_to_track.push_back($Player)
	NetworkManager.ggpo_multiplayer.nodes_to_track.push_back($Player2)
	
	NetworkManager.add_child(NetworkManager.ggpo_multiplayer)
	
	if NetworkManager.is_connected:
		$Player.player_num = 0
		$Player.player_id = NetworkManager.multiplayer_peer.get_unique_id()
	
	$CatTreeLevel.remove_child($CatTreeLevel/Camera2D)
	$CatTreeLevel.remove_child($CatTreeLevel/Player)
	$CatTreeLevel.remove_child($CatTreeLevel/Player2)


func _input(event):
	if event.is_action_pressed("host_1"):
		NetworkManager.ggpo_multiplayer.create_peer(11111, 2, 1)
	elif event.is_action_pressed("host_2"):
		NetworkManager.ggpo_multiplayer.create_peer(11112, 2, 2)
	elif event.is_action_pressed("client_1"):
		NetworkManager.ggpo_multiplayer.add_player("127.0.0.1", 11112)
	elif event.is_action_pressed("client_2"):
		NetworkManager.ggpo_multiplayer.add_player("127.0.0.1", 11111)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

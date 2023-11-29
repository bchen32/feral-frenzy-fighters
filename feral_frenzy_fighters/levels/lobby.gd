extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.water_level = 10000
	
	if NetworkManager.is_connected:
		$Player.player_num = 0
		$Player.player_id = NetworkManager.multiplayer_peer.get_unique_id()
	
	$CatTreeLevel.remove_child($CatTreeLevel/Camera2D)
	$CatTreeLevel.remove_child($CatTreeLevel/Player)
	$CatTreeLevel.remove_child($CatTreeLevel/Player2)
	
	$P1Respawn.set_spawn($CatTreeLevel/P1Spawn.position)
	$P2Respawn.set_spawn($CatTreeLevel/P2Spawn.position)
	
	$CatTreeLevel/Events/EventSpawner.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

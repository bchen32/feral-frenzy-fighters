extends Node2D

@export var _players: Array[PlayerCharacter] 

@onready var camera = $Camera2D

func _game_information(player_datas: Dictionary):
	for player_num in player_datas:
		var player = _players[player_num]
		var player_data = player_datas[player_num]
		
		assert("position" in player_data and \
			   "stock" in player_data and "percentage" in player_data and \
			   "state" in player_data and "flip_h" in player_data)
		
		player.stocks = player_data["stock"]
		player.percentage = player_data["percentage"]
		
		if player._damage_label != null:
			player._damage_label.set_player_death_count(player_num, player.stocks)
			player._damage_label.set_player_damage(player_num, player.percentage)
		
		if player.player_num != NetworkManager.my_player_num:
			player.position = player_data["position"]
			player.anim_player.flip_h = player_data["flip_h"]
			player.state_machine.transition(player_data["state"])

func _ack_death(player_num: int):
	assert(_players.size() > player_num)
	
	_players[player_num].acknowledge_death()

func _ack_hit(player_num: int, hit_info: Dictionary):
	assert(_players.size() > player_num)
	
	_players[player_num].acknowledge_hit(player_num, hit_info)

# Called when the node enters the scene tree for the first time.
func _ready():
	var level
	match Globals.stage:
		0:
			level = load("res://levels/cat_tree/cat_tree_level.tscn").instantiate()
			$AudioStreamPlayer.stream = preload("res://levels/cat_tree/music/catfight.wav")
			Globals.water_level = 10000
		1:
			level = load("res://levels/fish_tank/fish_tank_level.tscn").instantiate()
			$AudioStreamPlayer.stream = preload("res://levels/fish_tank/sfx/fishfight.wav")
			Globals.water_level = 120
		2:
			level = load("res://levels/turtle_habitat/turtle_habitat_level.tscn").instantiate()
			$AudioStreamPlayer.stream = preload("res://levels/cat_tree/music/catfight.wav")
			Globals.water_level = 10000
			
	$AudioStreamPlayer.play()
	add_child(level)
	$Player.set_spawn(level.get_node("P1Spawn").position)
	$Player2.set_spawn(level.get_node("P2Spawn").position)
	move_child(level, 0)
	camera.event_spawner = level.get_node("Events/EventSpawner")
	NetworkManager.recieved_player_data.connect(_game_information)
	NetworkManager.death_acked.connect(_ack_death)
	NetworkManager.hit_acked.connect(_ack_hit)
	
	# TODO(Bobby): impl this but for networking
	var prefix_path: String = "res://gui/menus/cutscenes/"
	var suffix_path: String = "%sp1_%sp2.ogv" % [Globals.player_sprites[0], Globals.player_sprites[1]]
	
	match Globals.stage:
		0:
			prefix_path += "cat_arena_outcomes/"
		1:
			prefix_path += "fish_arena_outcomes/"
		2:
			prefix_path += "turtle_arena_outcomes/"
	
	$Player.ending_video = "%sp2_win/%s" % [prefix_path, suffix_path]
	$Player2.ending_video = "%sp1_win/%s" % [prefix_path, suffix_path]
	
	Globals.setup_controls()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

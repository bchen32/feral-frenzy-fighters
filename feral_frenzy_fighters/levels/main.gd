extends Node2D

@export var _players: Array[PlayerCharacter] 
var stage

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
	NetworkManager.recieved_player_data.connect(_game_information)
	NetworkManager.death_acked.connect(_ack_death)
	NetworkManager.hit_acked.connect(_ack_hit)
	NetworkManager.damage_label = $Camera2D/CanvasLayer/DamageUI
	
	stage = Globals.selected_stage.instantiate()
	add_child(stage)
	Globals.setup_controls()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()

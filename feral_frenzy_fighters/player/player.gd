class_name PlayerCharacter
extends CharacterBody2D

@export var sprite_scene: PackedScene
@export var player_num: int = 0
@export var stocks: int = 3
@export var walk_accel: float = 6000.0
@export var dash_accel: float = 9000.0
@export var tilt_attack_accel: float = 1200.0
@export var dash_attack_accel: float = 1500.0
@export var air_accel: float = 3600.0
@export var walk_jump_accel: float = 800.0 # jump accels not scaled by delta
@export var dash_jump_accel: float = 1200.0
@export var air_jump_accel: float = 600.0
@export var walk_speed: float = 400.0
@export var dash_speed: float = 600.0
@export var dash_attack_speed: float = 750.0
@export var air_jump_speed: float = 400.0
@export var jump_speed: float = -1000.0
@export var terminal_vel: float = 1200.0
@export var fall_grav_scale: float = 1.8
@export var kb_base: float = 500.0
@export var kb_hitstun_scale: float = 0.015
@export var kb_decay: float = 1500.0
@export var inverse_weight: float = 10.0
@export var attacks: Dictionary = {
	"neutral":
	{
		"frames": 30,
		"damage": 10,
		"knockback_scale": 1.0,
		"knockback_x_offset": 10.0,
		"knockback_y_offset": -10.0,
		"hitboxes": [{"start_frame": 8, "end_frame": 16, "width": 28, "height": 10, "x_offset": 12, "y_offset": 0}]
	},
	"air_neutral":
	{
		"frames": 20,
		"damage": 10,
		"knockback_scale": 1.0,
		"knockback_x_offset": 0.0,
		"knockback_y_offset": 0.0,
		"hitboxes": [{"start_frame": 4, "end_frame": 20, "width": 40, "height": 40, "x_offset": 0, "y_offset": 0}]
	},
	"dash_attack":
	{
		"frames": 45,
		"damage": 15,
		"knockback_scale": 1.0,
		"knockback_x_offset": 20.0,
		"knockback_y_offset": -5.0,
		"hitboxes": [
			{"start_frame": 4, "end_frame": 24, "width": 20, "height": 40, "x_offset": 30, "y_offset": 0}
		]
	}
}
@export var _damage_label: Control
@export var _dead_areas: Node2D
@export var _ending_video = "res://gui/menus/cutscenes/cat_v_cat_win_cutscene.ogv"
@export var _ending_video_audiostream: AudioStream
@export var _is_lobby: bool = false

@onready var state_machine: Node = $StateMachine

@export var physics_blood: PackedScene

var anim_player: AnimatedSprite2D
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
var frame: int = 0
var percentage: float = 0.0
var air_speed_upper_bound: float = walk_speed
var air_speed_lower_bound: float = -walk_speed
var jumps_left: int = 3
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
# Be careful not to desync curr_hitboxes_ends from curr_hitboxes (sadly no tuples in GDScript)
var curr_hitboxes: Array[Node]
var curr_hitboxes_ends: Array[int]

# networking stuff
@export var chosen_attack: Dictionary
var display_name: String
var player_state_type: Globals.States
var stock: int
var player_id: int

# Knockback variables
var hit: bool = false
var kb: float = 0.0
var kb_angle: float = 0.0
var flip_h: bool = false

var _initial_player_position: Vector2
var beanbag: bool = false

var _attack_sfx = [
	preload("res://player/cat/sfx/attack/attack_1.wav"),
	preload("res://player/cat/sfx/attack/attack_2.wav"),
	preload("res://player/cat/sfx/attack/attack_3.wav")
]

var _dash_sfx = [
	preload("res://player/cat/sfx/dash/dash_1.wav")
]

var _death_sfx = [
	preload("res://player/cat/sfx/death/death_1.wav"),
	preload("res://player/cat/sfx/death/death_2.wav")
]

var _hit_sfx = [
	preload("res://player/cat/sfx/hit/hit_1.wav"),
	preload("res://player/cat/sfx/hit/hit_2.wav"),
	preload("res://player/cat/sfx/hit/hit_3.wav")
]

var _walk_sfx = [
	preload("res://player/cat/sfx/walk/walk_1.wav"),
	preload("res://player/cat/sfx/walk/walk_2.wav"),
	preload("res://player/cat/sfx/walk/walk_3.wav"),
	preload("res://player/cat/sfx/walk/walk_4.wav")
]

var _jump_sfx = [
	preload("res://player/cat/sfx/jump/double_jump.wav"),
	preload("res://player/cat/sfx/jump/single_jump.wav")
]

var _multiplayer_sync = MultiplayerSynchronizer.new()
var _sprites_scene_instance: Node

# Dash right now for the game jam is unused
enum AudioType { ATTACK, DASH, DEATH, HIT, WALK, JUMP }

func _ready():
	randomize()
	refresh_damage_label(_damage_label)
	
	if Globals.player_sprites.size() > player_num:
		sprite_scene = Globals.player_sprites[player_num]
	
	_sprites_scene_instance = sprite_scene.instantiate()
	
	add_child(_sprites_scene_instance)
	
	var sprite_node_path = NodePath(_sprites_scene_instance.name + "/AnimatedSprite2D:flip_h")
	
	_multiplayer_sync.replication_config.add_property(sprite_node_path)
	_multiplayer_sync.replication_config.property_set_spawn(sprite_node_path, true)
	_multiplayer_sync.replication_config.property_set_sync(sprite_node_path, true)
	_multiplayer_sync.replication_config.property_set_watch(sprite_node_path, false)
	
	if _damage_label:
		var player_head = _damage_label.get_node(("P2" if player_num else "P1") + "/TextureRect")
		if "cat" in _sprites_scene_instance.get_scene_file_path():
			if player_num:
				player_head.texture = load("res://gui/hud/sprites/head_icons/cat_head_icon_blue.png")
			else:
				player_head.texture = load("res://gui/hud/sprites/head_icons/cat_head_icon_purple.png")
		elif "fish" in _sprites_scene_instance.get_scene_file_path():
			player_head.texture = load("res://gui/hud/sprites/head_icons/fish_head_icon.png")
		elif "beanbag" in _sprites_scene_instance.get_scene_file_path():
			beanbag = true
	anim_player = _sprites_scene_instance.get_node("AnimatedSprite2D")
	var p1_icon
	var p2_icon
	if not beanbag:
		p1_icon = _sprites_scene_instance.get_node("Player1Icon")
		p2_icon = _sprites_scene_instance.get_node("Player2Icon")
	if _damage_label:
		_damage_label.set_player_death_count(player_num, stocks)

	if _dead_areas:
		for dead_area in _dead_areas.get_children():
			dead_area.body_entered.connect(_on_dead_area_entered)

	_initial_player_position = position
	if player_num == 1:
		anim_player.flip_h = false
		if p2_icon:
			p2_icon.visible = true
	else:
		anim_player.flip_h = true
		if p1_icon:
			p1_icon.visible = true
	state_machine.init(self)
	
	refresh_dead_areas(_dead_areas)

func refresh_dead_areas(new_dead_areas: Node2D):
	if _dead_areas:
		for dead_area in _dead_areas.get_children():
			if dead_area.body_entered.is_connected(_on_dead_area_entered):
				dead_area.body_entered.disconnect(_on_dead_area_entered)
		
	_dead_areas = new_dead_areas
	
	if _dead_areas:
		for dead_area in _dead_areas.get_children():
			dead_area.body_entered.connect(_on_dead_area_entered)

func refresh_damage_label(new_damage_label: Control):
	_damage_label = new_damage_label
	
	if _damage_label:
		_damage_label.set_player_death_count(player_num, stocks)

func reset_frame():
	frame = 0

func play_anim(animation_name: String):
	if beanbag: # beanbag only
		anim_player.play(animation_name)
	else:
		if percentage > 40:
			anim_player.play(("blue_" if player_num else "purple_") + "injured_" + animation_name)
		else:
			anim_player.play(("blue_" if player_num else "purple_") + animation_name)


func play_audio(audio_type: AudioType):
	if $SoundEffectPlayer.playing:
		$SoundEffectPlayer.stop()

	var audio_stream: AudioStream

	match audio_type:
		AudioType.ATTACK:
			audio_stream = _attack_sfx[randi_range(0, _attack_sfx.size() - 1)]
		AudioType.DASH:
			audio_stream = _dash_sfx[randi_range(0, _dash_sfx.size() - 1)]
		AudioType.DEATH:
			audio_stream = _death_sfx[randi_range(0, _death_sfx.size() - 1)]
		AudioType.HIT:
			audio_stream = _hit_sfx[randi_range(0, _hit_sfx.size() - 1)]
		AudioType.WALK:
			audio_stream = _walk_sfx[randi_range(0, _walk_sfx.size() - 1)]
		AudioType.JUMP: 
			audio_stream = _jump_sfx[randi_range(0, _jump_sfx.size() - 1)]
		
	$SoundEffectPlayer.stream = audio_stream
	$SoundEffectPlayer.play()

func blood_splatter(
	spread: float = 45, 
	amount: int = percentage,
	location: Vector2 = self.global_position, 
	direction: Vector3 = Vector3(0,0,0), 
	vel: Vector2 = Vector2(200,500)):
		
	var splatter = physics_blood.instantiate()
	splatter.amount = amount*2 + 25
	splatter.global_position = location
	splatter.process_material.direction = direction
	splatter.process_material.spread = spread
	splatter.process_material.initial_velocity_min = vel.x
	splatter.process_material.initial_velocity_max = vel.y
	
	get_parent().add_child(splatter)

func get_input(input_name: String):
	if NetworkManager.is_host:
		return input_name
	elif NetworkManager.is_connected:
		if _is_lobby or player_num == NetworkManager.my_player_num:
			return "p1_%s" % input_name
		else:
			# TODO(Bobby): Find a cleaner soln than just having a null_input
			return "null_input"
	else:
		return "p%s_%s" % [player_num + 1, input_name]


func _get_camera_size():
	# Get the canvas transform
	return get_viewport_rect().size / get_canvas_transform().get_scale()


func _get_camera_position():
	var canvas_transform = get_canvas_transform()

	return -canvas_transform.get_origin() / canvas_transform.get_scale()


func get_grav():
	return (
		gravity
		if velocity.y < 0
		else gravity * fall_grav_scale
	)


func update_attack(attack_name: String):
	for hitbox_stats in chosen_attack.hitboxes:
		if frame == hitbox_stats.start_frame:
			var hitbox = hitbox_scene.instantiate()
			add_child(hitbox)
			curr_hitboxes.append(hitbox)
			curr_hitboxes_ends.append(hitbox_stats.end_frame)
			hitbox.setup(
				hitbox_stats.width,
				hitbox_stats.height,
				(1.0 if anim_player.flip_h else -1.0) * hitbox_stats.x_offset,  # handles if sprite is facing other direction
				hitbox_stats.y_offset,
				chosen_attack.damage,
				chosen_attack.knockback_scale,
				(1.0 if anim_player.flip_h else -1.0) * chosen_attack.knockback_x_offset,
				chosen_attack.knockback_y_offset
			)
	for i in range(len(curr_hitboxes)):
		if frame == curr_hitboxes_ends[i]:
			curr_hitboxes[i].get_node("CollisionShape2D").disabled = true


func end_attack():
	for child in get_children():
		if child is Hitbox:
			child.queue_free()
	curr_hitboxes = []
	curr_hitboxes_ends = []
	
	chosen_attack = {}


func air_movement(delta):
	velocity.y += get_grav() * delta
	velocity.y = minf(velocity.y, terminal_vel)
	var direction = InputManager.get_axis(
		get_input("left"), get_input("right")
	)
	if direction:
		velocity.x += direction * air_accel * delta
		velocity.x = clamp(velocity.x, air_speed_lower_bound, air_speed_upper_bound)


func _on_dead_area_entered(body: Node2D):
	if body == self:
		acknowledge_death()


func acknowledge_hit(player_num: int, hit_info: Dictionary):
	hit = true
	percentage += hit_info["dmg"]
	kb = hit_info["kb"]
	kb_angle = hit_info["kb_angle"]
	global_position.y += hit_info["kb_y_offset"]
	play_audio(AudioType.HIT)
	

func acknowledge_death():
	var hit_direction = \
			(global_position - get_viewport().get_camera_2d().get_screen_center_position()).normalized()
		
	var center_screen: Vector2 = get_viewport().get_camera_2d().get_screen_center_position()
	
	var screen_pos = _get_camera_position()
	var screen_size = _get_camera_size()
	var screen_end = screen_pos + screen_size
	
	var ko_icon_position: Vector2 = Vector2()
	
	# just doing 4 directions now to simplify stuff
	if abs(hit_direction.x) > abs(hit_direction.y):
		if hit_direction.x > 0:
			ko_icon_position = Vector2(screen_end.x - 128, center_screen.y)
		else:
			ko_icon_position = Vector2(screen_pos.x, center_screen.y)
	else:
		if hit_direction.y > 0:
			ko_icon_position = Vector2(center_screen.x, screen_end.y - 128)
		else:
			ko_icon_position = Vector2(center_screen.x, screen_pos.y)
	
	var ko_icon_load = preload("res://gui/hud/ko_icon.tscn").instantiate()
	
	get_parent().add_child(ko_icon_load)
	
	ko_icon_load.global_position = ko_icon_position
	
	position = _initial_player_position
	velocity = Vector2(0, 0)
	percentage = 0
	
	if not NetworkManager.is_connected and not _is_lobby:
		stocks -= 1
		if _damage_label:
			_damage_label.set_player_death_count(player_num, stocks)
		
		if NetworkManager.is_host:
			NetworkManager.update_damage_label.rpc(player_num, 0, stocks)
		
		if not _is_lobby and stocks <= 0:
			if NetworkManager.is_host:
				NetworkManager._players_in_which_lobbies[player_id].on_player_completely_dead(player_num)
			
			Globals.player1_won = player_num != 0
			Globals.cutscene_player_end_game = true
			Globals.cutscene_player_video_path = _ending_video
			Globals.audio_stream_to_play_during_cutscene = _ending_video_audiostream
			get_tree().change_scene_to_file("res://gui/menus/cutscene_player.tscn")
	play_audio(AudioType.DEATH)
	
	if not NetworkManager.is_connected and not NetworkManager.is_host:
		blood_splatter(30, 200, ko_icon_position,-Vector3(hit_direction.x,hit_direction.y, 0),Vector2(100,1000))

func _physics_process(delta: float):
	# if we are the server setup, we need to tell InputManager which player to get inputs for
	
	if NetworkManager.is_host:
		InputManager.switch_player_id(player_id)
	
	set_collision_mask_value(4, not InputManager.is_action_pressed(get_input("down")))  # drop through platforms while down is held
	frame += 1
	state_machine.update(delta)
	move_and_slide()

func _process(_delta: float):
	if anim_player.flip_h:
		anim_player.position.x = -12
	else:
		anim_player.position.x = 12
	if "jump" in anim_player.animation or "fall" in anim_player.animation:
		anim_player.position.y = 8
	else:
		anim_player.position.y = -8
	if _damage_label and NetworkManager.is_host:
		_damage_label.set_player_damage(player_num, percentage)
	
	if NetworkManager.is_connected and (_is_lobby or player_num == NetworkManager.my_player_num):
		var input_actions = InputManager.get_input_actions(self)
		
		if not input_actions.is_empty():
			NetworkManager.send_network_input.rpc(input_actions)
		#NetworkManager.update_game_information.rpc(position, state_machine.curr_state,
		#										   anim_player.flip_h)

func _enter_tree():
	var multiplayer_replication_config: SceneReplicationConfig = $MultiplayerSynchronizer.replication_config
	var old_multiplayer_sync: MultiplayerSynchronizer = $MultiplayerSynchronizer
	var root_path: NodePath = $MultiplayerSynchronizer.root_path
	
	remove_child(old_multiplayer_sync)
	old_multiplayer_sync.queue_free()
	
	_multiplayer_sync = MultiplayerSynchronizer.new()
	
	_multiplayer_sync.name = NodePath("MultiplayerSynchronizer")
	_multiplayer_sync.replication_config = multiplayer_replication_config
	_multiplayer_sync.root_path = root_path
	
	call_deferred("add_child", _multiplayer_sync)


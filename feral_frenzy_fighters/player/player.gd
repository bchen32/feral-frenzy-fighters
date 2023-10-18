class_name PlayerCharacter
extends CharacterBody2D

@export var character_type: String
@export var character_data: Dictionary = {
	"cat":
	{
		"sprite_scene": "res://player/cat/cat.tscn",
		"stats": "res://player/cat/cat.json"
	},
	"fish":
	{
		"sprite_scene": "res://player/fish/fish.tscn",
		"stats": "res://player/fish/fish.json"
	},
	"beanbag":
	{
		"sprite_scene": "res://player/beanbag/beanbag.tscn",
		"stats": "res://player/cat/cat.json"
	}
}
@export var player_num: int = 0
@export var stocks: int = 3
@export var _damage_label: Control
@export var _dead_areas: Node2D
@export var _ending_video: String
@export var _ending_video_audiostream: AudioStream
@export var _is_lobby: bool = false

@onready var state_machine: Node = $StateMachine
@onready var CS = $CollisionShape2D
@onready var gamepad = Globals.player_gamepad[player_num]

@export var physics_blood:Array[PackedScene]
@export var dash_particles:Array[PackedScene]

var color: String = ""
var bloodied: bool = false
var anim_player: AnimatedSprite2D
var stats: Dictionary
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
var frame: int = 0
var percentage: float = 0.0
var air_speed_upper_bound: float
var air_speed_lower_bound: float
var jumps_left: int = 3
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
# Be careful not to desync curr_hitboxes_ends from curr_hitboxes (sadly no tuples in GDScript)
var curr_hitboxes: Array[Node]
var curr_hitboxes_ends: Array[int]

# Knockback variables
var hit: bool = false
var kb: float = 0.0
var kb_angle: float = 0.0
var flip_h: bool = false

var _initial_player_position: Vector2

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

# Dash right now for the game jam is unused
enum AudioType { ATTACK, DASH, DEATH, HIT, WALK, JUMP }


func _ready():
	randomize()
	if Globals.player_sprites.size() > player_num:
		character_type = Globals.player_sprites[player_num]
	stats = load_stats(character_data[character_type].stats)
	air_speed_lower_bound = -stats.walk_speed
	air_speed_upper_bound = stats.walk_speed
	var sprites = load(character_data[character_type].sprite_scene).instantiate()
	add_child(sprites)
	var player_head = _damage_label.get_node(("P2" if player_num else "P1") + "/TextureRect")
	anim_player = sprites.get_node("AnimatedSprite2D")
	var p1_icon
	var p2_icon
	if character_type != "beanbag":
		color = "blue" if player_num else "purple"
		player_head.texture = load("res://gui/hud/sprites/head_icons/" + character_type + "_head_icon_" + color + ".png")
		p1_icon = sprites.get_node("Player1Icon")
		p2_icon = sprites.get_node("Player2Icon")
		var states = {
			Globals.States.AIR: AirState.new(),
			Globals.States.AIR_ATTACK: AirAttackState.new(),
			Globals.States.AIR_JUMP: AirJumpState.new(),
			Globals.States.DASH: DashState.new(),
			Globals.States.DASH_ATTACK: DashAttackState.new(),
			Globals.States.DASH_JUMP: DashJumpState.new(),
			Globals.States.GROUND_ATTACK: GroundAttackState.new(),
			Globals.States.HIT: HitState.new(),
			Globals.States.IDLE: IdleState.new(),
			Globals.States.WALK: WalkState.new(),
			Globals.States.WALK_JUMP: WalkJumpState.new()
		}
		state_machine.init(self, states, Globals.States.IDLE)
	else:
		player_head.texture = load("res://gui/hud/sprites/head_icons/" + character_type + ".png")
		var states = {
			Globals.States.AIR: BeanbagAirState.new(),
			Globals.States.HIT: HitState.new(),
			Globals.States.IDLE: BeanbagIdleState.new()
		}
		state_machine.init(self, states, Globals.States.IDLE)
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


func load_stats(file_name: String):
	var file = FileAccess.open(file_name, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			return data_received
		else:
			print("Unexpected data in JSON Parse")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	return {}


func reset_frame():
	frame = 0


func play_anim(animation_name: String):
	if character_type == "beanbag":
		anim_player.play(animation_name)
	elif percentage > 40:
		anim_player.play("_".join([color, "injured", animation_name]))
		if !bloodied:
			bloodied = true
			play_particles(
			physics_blood,
			2,
			180,
			1)
	else:
		anim_player.play("_".join([color, animation_name]))


func play_audio(audio_type: AudioType):

	var audio_stream: AudioStream
	var audio_player = preload("res://player/playerSFX.tscn").instantiate()
	
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
		
	add_child(audio_player)
	audio_player.stream = audio_stream
	audio_player.play()

func play_particles(
	list: Array,
	index: int = 0,
	spread: float = 45, 
	amount: int = 1,
	location: Vector2 = self.global_position, 
	direction: Vector3 = Vector3(0,0,0), 
	vel: Vector2 = Vector2(200,500)):

	var splatter = list[index].instantiate()
	
	if splatter.get_class() == "GPUParticles2D":
		splatter.amount = amount
		splatter.global_position = location
		splatter.process_material.direction = direction
		splatter.process_material.spread = spread
		splatter.process_material.initial_velocity_min = vel.x
		splatter.process_material.initial_velocity_max = vel.y
		
	elif splatter.get_class() == "CPUParticles2D":
		splatter.amount = amount
		splatter.global_position = location
		splatter.direction = Vector2(direction.x,direction.y)
		splatter.spread = spread
		splatter.initial_velocity_min = vel.x
		splatter.initial_velocity_max = vel.y
	
	get_parent().add_child(splatter)
	splatter.emitting = true


func get_input(input_name: String):
	if NetworkManager.is_connected:
		if player_num == NetworkManager.my_player_num:
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
		else gravity * stats.fall_grav_scale
	)


func update_attack(attack_name: String):
	var attack = stats.attacks[attack_name]
	for hitbox_stats in attack.hitboxes:
		if frame == hitbox_stats.start_frame:
			var hitbox = hitbox_scene.instantiate()
			add_child(hitbox)
			curr_hitboxes.append(hitbox)
			curr_hitboxes_ends.append(int(hitbox_stats.end_frame))
			hitbox.setup(
				hitbox_stats.width,
				hitbox_stats.height,
				(1.0 if anim_player.flip_h else -1.0) * hitbox_stats.x_offset,  # handles if sprite is facing other direction
				hitbox_stats.y_offset,
				attack.damage,
				attack.knockback_scale,
				(1.0 if anim_player.flip_h else -1.0) * attack.knockback_x_offset,
				attack.knockback_y_offset
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


func air_movement(delta):
	velocity.y += get_grav() * delta
	velocity.y = minf(velocity.y, stats.terminal_vel)
	var direction = Input.get_axis(
		get_input("left"), get_input("right")
	)
	if direction:
		velocity.x += direction * stats.air_accel * delta
		velocity.x = clamp(velocity.x, air_speed_lower_bound, air_speed_upper_bound)


func _on_dead_area_entered(body: Node2D):
	if body == self:
		if not _is_lobby and NetworkManager.is_connected:
			NetworkManager.report_death.rpc(player_num)
		else:
			acknowledge_death()


func acknowledge_hit(player_num: int, hit_info: Dictionary):
	hit = true
	percentage += hit_info["dmg"]
	kb = hit_info["kb"]
	kb_angle = hit_info["kb_angle"]
	global_position.y += hit_info["kb_y_offset"]


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
	
	position = _initial_player_position # needs to reload state machine (hit stun carries over)
	velocity = Vector2(0, 0)
	percentage = 0
	bloodied = false
	
	if not NetworkManager.is_connected and not _is_lobby:
		stocks -= 1
		if _damage_label:
			_damage_label.set_player_death_count(player_num, stocks)
		
		if not _is_lobby and stocks <= 0:
			Globals.player1_won = player_num != 0
			Globals.cutscene_player_end_game = true
			Globals.cutscene_player_video_path = _ending_video
			Globals.audio_stream_to_play_during_cutscene = _ending_video_audiostream
			get_tree().change_scene_to_file("res://gui/menus/cutscene_player.tscn")
	play_audio(AudioType.DEATH)
	play_particles(physics_blood,0, 30, 200, ko_icon_position,-Vector3(hit_direction.x,hit_direction.y, 0),Vector2(100,1000))

func _physics_process(delta: float):
	set_collision_mask_value(4, not Input.is_action_pressed(get_input("down")))  # drop through platforms while down is held
	frame += 1
	move_and_slide()
	state_machine.update(delta)

func _process(_delta: float):
	if character_type == "cat":
		if anim_player.flip_h:
			anim_player.position.x = -12
		else:
			anim_player.position.x = 12
		if "jump" in anim_player.animation or "fall" in anim_player.animation:
			anim_player.position.y = 8
		else:
			anim_player.position.y = -8
	if _damage_label:
		_damage_label.set_player_damage(player_num, percentage)
	
	if NetworkManager.is_connected and player_num == NetworkManager.my_player_num:
		NetworkManager.update_game_information.rpc(position, state_machine.curr_state,
												   anim_player.flip_h)

extends Interactable

var unstable = false
var original_position
var current_position
var destination
var amount_of_times_moved = 0
var max_times_to_move = 5
var speed
var reset_speed
var min_destination_distance = 1000

var env_data: Array

#hitbox settings: search "plasma_hitbox"
var hitbox_scene: PackedScene = preload("res://player/attacks/hitbox.tscn")
@export var particles: PackedScene
@onready var sprite = self.get_node("PlasmaBallSprite")
@onready var anim = self.get_node("AnimationPlayer")
@onready var event_spawner = $"../../Events/EventSpawner"
@onready var hitbox = self.get_node("Hitbox")
@onready var samples = [
	preload("res://levels/cat_tree/sfx/events/Zap1.wav"),
	preload("res://levels/cat_tree/sfx/events/Zap2.wav"),
	preload("res://levels/cat_tree/sfx/events/Zap3.wav")
]
@onready var start_vol = $Ambient.volume_db

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = 30
	self.maxHealth = self.health
	original_position = self.position
	current_position = self.position
	destination = Vector2(0, 0) # just to set variable to be a vector2
	speed = 2000
	reset_speed = speed
	self.self_modulate = Color.WHITE
	
	if NetworkManager.is_connected:
		NetworkManager.on_send_env_data.connect(_on_send_env_data)
		NetworkManager.env_hit_acked.connect(_on_env_hit_acked)

func _on_env_hit_acked(env_part: String, health_change: int):
	var env_part_name: String = name
	
	if env_part_name == env_part:
		_change_health(health_change)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if unstable == true && sprite.get_child_count() > 0:
		_move_ball(delta)

func _process(delta):
	if self.health <= 0 && unstable == false:
		_stability_change(true)
		unstable = true
	
	if unstable == true:
		event_spawner.change_set_overview(true)

func _change_health(health_change: float):
	if unstable == false:
		self.health += health_change
		if anim.is_playing():
			anim.stop()
		
		if self.health > 0:
			var audio_player = preload("res://player/playerSFX.tscn").instantiate()
			add_child(audio_player)
			audio_player.volume_db = -12
			audio_player.stream = samples[randi() % samples.size()]
			audio_player.play()
			anim.play("Damage")
			var sparks = particles.instantiate()
			sparks.global_position = global_position
			get_parent().add_child(sparks)
			sparks.emitting = true
			await anim.animation_finished
			if !hitbox.get_overlapping_bodies().is_empty():
				anim.play("Indication")

func _stability_change(turning_unstable: bool):
	if turning_unstable == true:
		$Ambient.volume_db = -15
		anim.play("StabilityChange")
		var audio_player = preload("res://player/playerSFX.tscn").instantiate()
		add_child(audio_player)
		audio_player.volume_db = start_vol
		audio_player.stream = samples[randi() % samples.size()]
		audio_player.play()
		await anim.animation_finished
		
		if NetworkManager.is_connected:
			NetworkManager.get_env_data.rpc("plasma_ball")
		else:
			_choose_random_point()
	elif turning_unstable == false:
		$Ambient.volume_db = start_vol
		sprite.get_child(0).queue_free()
		anim.play_backwards("StabilityChange")
		await anim.animation_finished
		
		if event_spawner.current_event_happening == false:
			event_spawner.change_set_overview(false)
		
		self.health = self.maxHealth
		speed = reset_speed
		amount_of_times_moved = 0
		unstable = false

func _on_send_env_data(env_name: String, new_env_data: Array):
	if env_name == "plasma_ball":
		env_data = new_env_data
		_choose_random_point()

func _choose_random_point():
	if NetworkManager.is_connected:
		destination = env_data[amount_of_times_moved]
	else:
		var rand_x = randi_range(0, 1920)
		var rand_y = randi_range(0, 1080)
		destination = Vector2(rand_x, rand_y)
	
	if self.position.distance_to(destination) < min_destination_distance and not NetworkManager.is_connected:
		_choose_random_point()
	else:
		amount_of_times_moved += 1
		
		var plasma_hitbox = hitbox_scene.instantiate()
		sprite.add_child(plasma_hitbox)
		
		# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
		plasma_hitbox.setup(50, 50, 0, 0, 15, 2, 0, 0, false)

func _move_ball(delta):
	if !self.position.distance_to(destination) < 0.1: # if the plasma ball hasn't reached the destination
		self.position = self.position.move_toward(destination, speed * delta)
	
	elif self.position.distance_to(destination) < 0.1 && !self.position.distance_to(original_position) < 0.1: # otherwise, if the plasma ball reaches the destination and it's NOT the original position
		speed -= reset_speed / 6
		
		if amount_of_times_moved >= max_times_to_move:
			destination = original_position
		elif amount_of_times_moved < max_times_to_move: 
			sprite.get_child(0).queue_free()
			_choose_random_point()
	
	elif self.position.distance_to(destination) < 0.1 && self.position.distance_to(original_position) < 0.1: # otherwise, if the plasma ball reaches the destination and IT IS the original position
		_stability_change(false)

func _on_hitbox_body_entered(body):
	if unstable == false:
		anim.play("Indication")

func _on_hitbox_body_exited(body):
	if unstable == false:
		if hitbox.get_overlapping_bodies().is_empty():
			anim.play("RESET")

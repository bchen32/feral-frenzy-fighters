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

#hitbox settings: line 90
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@export var particles: PackedScene
@onready var sprite = self.get_node("PlasmaBallSprite")
@onready var anim = self.get_node("AnimationPlayer")
@onready var event_spawner = $"../../Events/EventSpawner"
@onready var hitbox = self.get_node("Hitbox")

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
		anim.play("StabilityChange")
		await anim.animation_finished
		
		_choose_random_point()
	elif turning_unstable == false:
		sprite.get_child(0).queue_free()
		anim.play_backwards("StabilityChange")
		await anim.animation_finished
		
		if event_spawner.current_event_happening == false:
			event_spawner.change_set_overview(false)
		
		self.health = self.maxHealth
		speed = reset_speed
		amount_of_times_moved = 0
		unstable = false

func _choose_random_point():
	var rand_x = randi_range(0, 1920)
	var rand_y = randi_range(0, 1080)
	destination = Vector2(rand_x, rand_y)
	
	if self.position.distance_to(destination) < min_destination_distance:
		_choose_random_point()
	else:
		amount_of_times_moved += 1
		
		var plasma_hitbox = hitbox_scene.instantiate()
		sprite.add_child(plasma_hitbox)
		
		# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
		plasma_hitbox.setup(50, 50, 0, 0, 15, 2, 0, 0)

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

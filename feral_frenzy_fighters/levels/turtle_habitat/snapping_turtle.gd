extends Node2D

var reset_hitbox_rate: int = 1
var max_detection_range: int = 400

var current_speed: float
var idle_speed: float = 3
var chase_speed: float = 6
var death_speed: float = 1

var dead: bool = false
var death_rotation: float = randf_range(-0.1, 0.1)
var destination: Vector2

#hitbox settings: search "turtle_hitbox"
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@onready var snapping_spawner: Node2D = get_parent()
@onready var anim_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var area: Area2D = get_node("Area2D")
@onready var anim: AnimationPlayer = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	if position.x < 1000:
		destination = Vector2(420, self.global_position.y)
		anim.play("LeftSwimParticle")
	elif position.x > 1000:
		destination = Vector2(1500, self.global_position.y)
	reset_hitbox()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("snapping_turtle: global_position = ", global_position)
	if dead == false:
		if !snapping_spawner.submerged_players.is_empty():
			for p in snapping_spawner.submerged_players:
				if global_position.distance_to(p.global_position) < max_detection_range:
					destination = p.global_position
					current_speed = chase_speed
		else:
			current_speed = idle_speed

func _physics_process(delta):
	if dead == false:
		visual_fix()
	
	move_turtle()

func move_turtle():
	if global_position.distance_to(destination) > 0.1:
		global_position = global_position.move_toward(destination, current_speed)
	elif global_position.distance_to(destination) < 0.1:
		idle_choose_point()
	
	if dead == true:
		rotation += death_rotation

func idle_choose_point():
	var rand_x = randi_range(0, 1920)
	var rand_y = randi_range(450, 990)
	destination = Vector2(rand_x, rand_y)

func visual_fix():
	var direction = global_position.direction_to(destination)
	
	if direction.x > 0:
		anim_sprite.flip_h = true
		anim.play("SwimmingRightParticle")
	else:
		anim_sprite.flip_h = false
		anim.play("SwimmingLeftParticle")

func reset_hitbox():
	if dead == false:
		if !anim_sprite.get_children().is_empty():
			anim_sprite.get_child(0).queue_free()
		
		var turtle_hitbox = hitbox_scene.instantiate()
		anim_sprite.add_child(turtle_hitbox)
		
		# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
		turtle_hitbox.setup(105, 40, 0, 0, 10, 1.5, 0, 0)
		
		await get_tree().create_timer(reset_hitbox_rate).timeout
		reset_hitbox()

func death():
	dead = true
	anim_sprite.play("Death")
	anim.play("Death")
	destination = Vector2(global_position.x, global_position.y + 50)
	current_speed = death_speed
	await get_tree().create_timer(3).timeout
	queue_free()


func _on_area_2d_body_entered(body):
	anim_sprite.play("SwimAttacking")


func _on_area_2d_body_exited(body):
	if area.has_overlapping_bodies() == false:
		anim_sprite.play("Swimming")

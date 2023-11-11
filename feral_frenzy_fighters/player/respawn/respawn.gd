extends Node2D

enum Capsule_States {NOCAPSULE, FLYINGIN, WAITING, FLYINGOUT}
var capsule_state = Capsule_States.NOCAPSULE

@export var p1_respawn: bool

var capsule_spawn_pos: Vector2
var player_respawn_pos: Vector2
var capsule_end_pos: Vector2
var capsule_destination: Vector2

@onready var capsule: Node2D = get_node("Capsule")
@onready var anim: AnimationPlayer = get_node("Capsule/AnimationPlayer")
@onready var capsule_sprites_array = [
	load("res://player/respawn/sprites/test_tube_respawn_blue_no_bottom.png"),
	load("res://player/respawn/sprites/test_tube_respawn_purple_no_bottom.png"),
	load("res://player/respawn/sprites/rocket_purple_fire2.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	if p1_respawn == false:
		$Capsule/CapsuleSprite/LeftRocket.texture = capsule_sprites_array[2]
		$Capsule/CapsuleSprite/RightRocket.texture = capsule_sprites_array[2]

func set_spawn(player_spawn):
	player_respawn_pos = player_spawn
	
	capsule_spawn_pos = Vector2(2500, player_spawn.y)
	capsule_end_pos = Vector2(-500, player_spawn.y)
	
	set_capsule_stuff()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	capsule_movement()

func capsule_movement():
	if capsule.position.distance_to(capsule_destination) > 0.1:
		capsule.position = capsule.position.move_toward(capsule_destination, 10)
	elif capsule.position.distance_to(capsule_destination) <= 0.1:
		if capsule_state == Capsule_States.FLYINGIN:
			capsule_state = Capsule_States.WAITING
			set_capsule_stuff()
		elif capsule_state == Capsule_States.FLYINGOUT:
			capsule_state = Capsule_States.NOCAPSULE
			set_capsule_stuff()

func respawn_player():
	await get_tree().create_timer(2).timeout
	capsule_state = Capsule_States.FLYINGIN
	set_capsule_stuff()

func set_capsule_stuff():
	match capsule_state:
		Capsule_States.NOCAPSULE:
			anim.play("RESET")
			capsule.position = capsule_spawn_pos
			capsule_destination = capsule_spawn_pos
			if p1_respawn:
				$Capsule/CapsuleSprite.texture = capsule_sprites_array[0]
			else:
				$Capsule/CapsuleSprite.texture = capsule_sprites_array[1]
		Capsule_States.FLYINGIN:
			anim.play("FlyingIn")
			capsule_destination = player_respawn_pos
		Capsule_States.WAITING:
			anim.play("Stopping")
		Capsule_States.FLYINGOUT:
			anim.play("OpenThenFlyOut")
			await anim.animation_finished
			capsule_destination = capsule_end_pos

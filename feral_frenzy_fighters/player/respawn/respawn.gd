extends Node2D

enum Capsule_States {NOCAPSULE, FLYINGIN, WAITING, FLYINGOUT}
var capsule_state = Capsule_States.NOCAPSULE

@export var p1_respawn: bool
var capsule_delay = 3 # how long it takes for respawn capsule to fly in
var capsule_auto_drop_delay = 5 # how long players can wait in capsule before it auto drops them
var keep_player = false

var capsule_right_pos: Vector2
var capsule_left_pos: Vector2
var player_respawn_pos: Vector2
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
		$Capsule/OpenLiquidParticles.color = Color(171, 153, 194)

func set_spawn(player_spawn):
	player_respawn_pos = player_spawn
	
	capsule_right_pos = Vector2(2500, player_spawn.y)
	capsule_left_pos = Vector2(-500, player_spawn.y)
	
	set_capsule_stuff(Capsule_States.NOCAPSULE)

func _physics_process(delta):
	capsule_movement(delta)

func capsule_movement(delta):
	if !anim.is_playing():
		if capsule.position.distance_to(capsule_destination) > 0.1:
			capsule.position = capsule.position.move_toward(capsule_destination, 500 * delta)
		elif capsule.position.distance_to(capsule_destination) <= 0.1:
			if capsule_state == Capsule_States.FLYINGIN:
				set_capsule_stuff(Capsule_States.WAITING)
			elif capsule_state == Capsule_States.FLYINGOUT:
				set_capsule_stuff(Capsule_States.NOCAPSULE)
	
	if keep_player:
		if p1_respawn:
			$"../Player".global_position = capsule.global_position
			$"../Player".global_rotation = $Capsule/CapsuleSprite.global_rotation
		else:
			$"../Player2".global_position = capsule.global_position
			$"../Player2".global_rotation = $Capsule/CapsuleSprite.global_rotation
		
		if capsule_state == Capsule_States.WAITING && !anim.is_playing():
			if Input.is_anything_pressed():
				set_capsule_stuff(Capsule_States.FLYINGOUT)

func respawn_player():
	lock_player(true)
	
	if p1_respawn:
		$"../Player".set_process(false)
	else:
		$"../Player2".set_process(false)
	
	await get_tree().create_timer(capsule_delay).timeout
	set_capsule_stuff(Capsule_States.FLYINGIN)

func lock_player(lock: bool):
	var player: PlayerCharacter
	if p1_respawn:
		player = $"../Player"
	else:
		player = $"../Player2"
	
	if lock:
		player.set_collision_layer_value(1, false)
		player.set_collision_mask_value(2, false)
		keep_player = true
	else:
		player.set_collision_layer_value(1, true)
		player.set_collision_mask_value(2, true)
		keep_player = false

func set_capsule_stuff(new_state: Capsule_States): #p1 capsule left to right, p2 capsule vice versa
	capsule_state = new_state
	print("respawn: new capsule_state = ", capsule_state)
	
	match capsule_state:
		Capsule_States.NOCAPSULE:
			anim.play("RESET")
			if p1_respawn:
				$Capsule/CapsuleSprite.texture = capsule_sprites_array[0]
				capsule.position = capsule_left_pos
				capsule_destination = capsule_left_pos
			else:
				$Capsule/CapsuleSprite.texture = capsule_sprites_array[1]
				capsule.position = capsule_right_pos
				capsule_destination = capsule_right_pos
		Capsule_States.FLYINGIN:
			if p1_respawn:
				anim.play("FlyingInFromLeft")
			else:
				anim.play("FlyingInFromRight")
			capsule_destination = player_respawn_pos
		Capsule_States.WAITING:
			if p1_respawn:
				anim.play("StoppingFromLeft")
			else:
				anim.play("StoppingFromRight")
			await anim.animation_finished
			
			if p1_respawn:
				$"../Player".set_process(true)
			else:
				$"../Player2".set_process(true)
			
			await get_tree().create_timer(capsule_auto_drop_delay).timeout
			if keep_player:
				set_capsule_stuff(Capsule_States.FLYINGOUT)
		Capsule_States.FLYINGOUT:
			lock_player(false)
			anim.play("OpenThenFlyOut")
			await anim.animation_finished
			capsule_destination = capsule_left_pos

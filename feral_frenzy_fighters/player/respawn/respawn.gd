extends Node2D

enum Capsule_States {NOCAPSULE, FLYINGIN, WAITING, FLYINGOUT}
var capsule_state = Capsule_States.NOCAPSULE

@export var p1_respawn: bool
var capsule_delay = 1 # how long it takes for respawn capsule to fly in
var capsule_auto_drop_delay = 5 # how long players can wait in capsule before it auto drops them
var keep_player = false
var waiting_to_respawn = false

var capsule_right_pos: Vector2
var capsule_left_pos: Vector2
var player_respawn_pos: Vector2
var capsule_destination: Vector2

signal destination_reached(new_state)

@onready var capsule: Node2D = get_node("Capsule")
@onready var anim: AnimationPlayer = get_node("Capsule/AnimationPlayer")
@onready var capsule_sprites_array = [
	load("res://player/respawn/sprites/test_tube_respawn_blue_no_bottom.png"),
	load("res://player/respawn/sprites/test_tube_respawn_purple_no_bottom.png"),
	load("res://player/respawn/sprites/rocket_purple_fire2.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	if p1_respawn:
		$Capsule/OpenLiquidParticles.color = Color(0.74, 0.68, 0.82) #Blue = 121, 189, 215 | Purple = 171, 153, 194
		$Capsule/CapsuleSprite/LeftRocket.texture = capsule_sprites_array[2]
		$Capsule/CapsuleSprite/RightRocket.texture = capsule_sprites_array[2]

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
			capsule.position = capsule.position.move_toward(capsule_destination, 650 * delta)
		elif capsule.position.distance_to(capsule_destination) <= 0.1:
			if capsule_state == Capsule_States.FLYINGIN:
				#set_capsule_stuff(Capsule_States.WAITING)
				destination_reached.emit(Capsule_States.WAITING)
			elif capsule_state == Capsule_States.FLYINGOUT:
				#set_capsule_stuff(Capsule_States.NOCAPSULE)
				destination_reached.emit(Capsule_States.NOCAPSULE)
	
	if keep_player:
		if p1_respawn:
			$"../Player".global_position = capsule.global_position
			$"../Player".global_rotation = $Capsule/CapsuleSprite.global_rotation
		else:
			$"../Player2".global_position = capsule.global_position
			$"../Player2".global_rotation = $Capsule/CapsuleSprite.global_rotation
		
		if capsule_state == Capsule_States.WAITING && !anim.is_playing():
			if p1_respawn && (Input.is_action_pressed("p1_up") || Input.is_action_pressed("p1_down") || \
			Input.is_action_pressed("p1_left") || Input.is_action_pressed("p1_right")):
				set_capsule_stuff(Capsule_States.FLYINGOUT)
			
			if p1_respawn == false && (Input.is_action_pressed("p2_up") || Input.is_action_pressed("p2_down") || \
			Input.is_action_pressed("p2_left") || Input.is_action_pressed("p2_right")):
				set_capsule_stuff(Capsule_States.FLYINGOUT)

func respawn_player():
	if p1_respawn:
		$"../Player".set_process(false)
		$"../Player".set_physics_process(false)
	else:
		$"../Player2".set_process(false)
		$"../Player2".set_physics_process(false)
	
	if capsule_state == Capsule_States.NOCAPSULE:
		lock_player(true)
		await get_tree().create_timer(capsule_delay).timeout
		set_capsule_stuff(Capsule_States.FLYINGIN)
	else:
		waiting_to_respawn = true

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
				$Capsule/CapsuleSprite.texture = capsule_sprites_array[1]
				capsule.position = capsule_left_pos
				capsule_destination = capsule_left_pos
			else:
				$Capsule/CapsuleSprite.texture = capsule_sprites_array[0]
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
				$"../Player".set_physics_process(true)
			else:
				$"../Player2".set_process(true)
				$"../Player2".set_physics_process(true)
			
			await get_tree().create_timer(capsule_auto_drop_delay).timeout
			if keep_player:
				set_capsule_stuff(Capsule_States.FLYINGOUT)
		Capsule_States.FLYINGOUT:
			lock_player(false)
			anim.play("OpenThenFlyOut")
			await anim.animation_finished
			capsule_destination = capsule_left_pos


func _on_destination_reached(new_state):
	set_capsule_stuff(new_state)
	
	if waiting_to_respawn && new_state == Capsule_States.NOCAPSULE:
		await get_tree().create_timer(0.2).timeout
		respawn_player()
		waiting_to_respawn = false

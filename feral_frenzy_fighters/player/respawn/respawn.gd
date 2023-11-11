extends Node2D

var capsule_spawn_pos: Vector2
var p1_spawn_pos: Vector2
var p2_spawn_pos: Vector2
var capsule_end_pos: Vector2
@onready var p1_capsule: Node2D = get_node("P1Capsule")
@onready var p2_capsule: Node2D = get_node("P2Capsule")
@onready var p1_anim: AnimationPlayer = get_node("P1Capsule/AnimationPlayer")
@onready var p2_anim: AnimationPlayer = get_node("P2Capsule/AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_spawn(p1_spawn, p2_spawn):
	p1_spawn_pos = p1_spawn
	p2_spawn_pos = p2_spawn
	
	capsule_spawn_pos = Vector2(2500, p1_spawn.y)
	capsule_end_pos = Vector2(-500, p1_spawn.y)
	
	p1_anim.play("RESET")
	p2_anim.play("RESET")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

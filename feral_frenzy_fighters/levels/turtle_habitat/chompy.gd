extends Node2D

enum Chompy_States {SEEKING, STRETCHING, SNAPPING}
var chompy_state = Chompy_States.SEEKING

var target_player: Node2D
var target_pos: Vector2

var min_seeking_time = 5
var max_seeking_time = 10

var seeking_speed = 15
var stretching_speed = 30
var return_speed = 7

var SFX = [
	preload("res://levels/turtle_habitat/sfx/Rustle.mp3"),
	preload("res://levels/turtle_habitat/sfx/Chomp.mp3")
]

var process = false

#hitbox settings: search "plasma_hitbox"
var hitbox_scene: PackedScene = preload("res://player/attacks/hitbox.tscn")
@onready var p1 = self.get_tree().get_nodes_in_group("players").front()
@onready var p2 = self.get_tree().get_nodes_in_group("players").back()
@onready var anim = get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.get_tree().has_group("players") == false:
		target_pos = Vector2(randi_range(150, 1770), randi_range(350, 900))
		min_seeking_time = 2
		max_seeking_time = 2
	else:
		var players = [p1, p2]
		target_player = players.pick_random()
	chompy_single_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if process == true:
		chompy_process()

func chompy_single_process():
	match chompy_state:
		Chompy_States.SEEKING:
			process = true
			$ChompySFX.stream = SFX[0]
			$ChompySFX.play()
			await get_tree().create_timer(randi_range(min_seeking_time, max_seeking_time)).timeout
			process = false
			chompy_state = Chompy_States.STRETCHING
			chompy_single_process()
		Chompy_States.STRETCHING:
			anim.play("Stretching")
			await anim.animation_finished
			process = true
		Chompy_States.SNAPPING:
			var chompy_hitbox = hitbox_scene.instantiate()
			self.add_child(chompy_hitbox)
			
			# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
			chompy_hitbox.setup(60, 60, 0, 0, 25, 2, 0, 0, false)
			
			anim.play("Snap")
			$ChompySFX.stream = SFX[1]
			$ChompySFX.play()
			await anim.animation_finished
			chompy_hitbox.queue_free()
			
			await get_tree().create_timer(1).timeout
			process = true

func chompy_process():
	match chompy_state:
		Chompy_States.SEEKING:
			if self.get_tree().has_group("players") == true:
				target_pos = target_player.global_position
			global_position = global_position.move_toward(Vector2(target_pos.x, 0), seeking_speed)
		Chompy_States.STRETCHING:
			global_position = global_position.move_toward(target_pos, stretching_speed)
			if global_position.distance_to(target_pos) < 0.1:
				chompy_state = Chompy_States.SNAPPING
				chompy_single_process()
				process = false
		Chompy_States.SNAPPING:
			target_pos = Vector2(global_position.x, -150)
			global_position = global_position.move_toward(target_pos, return_speed)
			if global_position.distance_to(target_pos) < 0.1:
				self.queue_free()

extends Node2D

var bubble_time = 7
var min_time_between = 5
var max_time_between = 10
@onready var anim = self.get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	_cycle()

func _cycle():
	await get_tree().create_timer(randi_range(min_time_between, max_time_between)).timeout
	
	anim.play("Opening")
	await anim.animation_finished
	
	await get_tree().create_timer(bubble_time).timeout
	
	anim.play("Closing")
	await anim.animation_finished
	
	_cycle()

func _on_area_2d_body_entered(body):
	body.fall_grav_scale *= -1

func _on_area_2d_body_exited(body):
	body.fall_grav_scale *= -1

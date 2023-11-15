extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var initialized: bool = false
var first_frame: bool = true
var velocity: Vector2 = Vector2(0, 0)
var travel_anim: String
var collide_anim: String
var collide_frames: int
var frame: int = 0
var dead: bool = false

func setup(h_box, vel, travel_animation, collide_animation, col_frames):
	add_child(h_box)
	velocity = vel
	initialized = true
	travel_anim = travel_animation
	collide_anim = collide_animation
	collide_frames = col_frames


func collide():
	if not initialized:
		pass
	frame = 0
	dead = true
	if first_frame:
		anim.flip_h = velocity.x > 0
		first_frame = false
	velocity = Vector2(0, 0)
	anim.play(collide_anim)


func out_of_bounds():
	return global_position.x < -200 or global_position.x > 2120 or global_position.y < -200 or global_position.y > 1280


func _physics_process(delta):
	if not initialized:
		pass
	if (dead and frame == collide_frames) or out_of_bounds():
		queue_free()
	if first_frame:
		anim.play(travel_anim)
		anim.flip_h = velocity.x > 0
		first_frame = false
	frame += 1
	position += velocity * delta

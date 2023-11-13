extends Node2D
class_name Projectile


var initialized: bool = false
var velocity: Vector2 = Vector2(0, 0)

func setup(h_box, vel):
	add_child(h_box)
	velocity = vel
	initialized = true


func collide():
	queue_free()


func _process(delta):
	if not initialized:
		pass
	position += velocity * delta

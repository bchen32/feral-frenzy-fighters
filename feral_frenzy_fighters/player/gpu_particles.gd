extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var position_diff = global_position - get_viewport_rect().size / 2
	visibility_rect.position -= position_diff
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

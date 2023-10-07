extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = get_viewport().size.x
	
	
	# Change position x to 512 over 2 seconds
	# Also add a bounce at the end of the transition:
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

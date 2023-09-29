extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fade")


func _on_animation_player_animation_finished(anim_name):
	assert(anim_name == "fade")
	queue_free()

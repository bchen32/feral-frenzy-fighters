extends HBoxContainer

const heart = preload("res://gui/hud/heart.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_num_lives(num_lives):
	var lives_left = get_child_count()
	if num_lives > lives_left:
		for i in range(lives_left, num_lives):
			add_child(heart.instantiate())
	elif num_lives < lives_left:
		for i in range(num_lives, lives_left):
			remove_child(get_child(0))
	else:
		pass

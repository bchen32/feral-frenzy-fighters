extends CenterContainer

var lives = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	print("initializing num lives")
	$LivesLeft.set_num_lives(lives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_kill_pressed():
	lives = lives - 1
	$LivesLeft.set_num_lives(lives)

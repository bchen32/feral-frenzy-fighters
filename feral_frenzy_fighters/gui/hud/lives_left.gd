extends HBoxContainer

@onready var heart = preload("res://gui/hud/heart.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_num_lives(num_lives):
	await self.ready
	for i in range(get_child_count()):
		remove_child(get_child(0))
	for i in range(num_lives):
		add_child(heart.instantiate())

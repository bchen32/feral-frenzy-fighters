extends Node2D

@onready var anim = get_node("AnimationPlayer")
@onready var trapped_pos = get_node("Sprite2D/TrappedPosition")
var players_caught = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#self.position = Vector2(-500, 0) # makes sure on spawn fish net isn't on screen, only if delaying
	#await get_tree().create_timer(0.5).timeout
	var rand_side = randi_range(0, 1)
	if rand_side == 0:
		anim.play("NetFromLeft")
	else:
		anim.play("NetFromRight")
	
	await anim.animation_finished
	
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !players_caught.is_empty():
		for p in players_caught:
			players_caught[p].position = trapped_pos.position

func _on_area_2d_body_entered(body):
	players_caught.append(body)

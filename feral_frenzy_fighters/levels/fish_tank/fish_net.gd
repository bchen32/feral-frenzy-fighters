extends Node2D

class_name FishNet

@onready var anim = get_node("AnimationPlayer")
@onready var trapped_pos = get_node("Sprite2D/TrappedPosition")
var event_network_data: Array
var players_caught = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#self.position = Vector2(-500, 0) # makes sure on spawn fish net isn't on screen, only if delaying
	#await get_tree().create_timer(0.5).timeout
	var rand_side: int
	if NetworkManager.is_connected:
		rand_side = event_network_data[0]
	else:
		rand_side = randi_range(0, 1)
	
	
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
			p.global_position = trapped_pos.global_position
			
			if trapped_pos.global_position.y <= -345:
				players_caught.clear()

func _on_area_2d_body_entered(body):
	players_caught.append(body)

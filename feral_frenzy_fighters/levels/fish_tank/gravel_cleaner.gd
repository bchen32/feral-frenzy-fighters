extends Node2D

class_name GravelCleaner

@onready var anim = get_node("AnimationPlayer")
var event_network_data: Array
var players_caught = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_side: int
	
	if NetworkManager.is_connected:
		rand_side = event_network_data[0]
	else:
		rand_side = randi_range(0, 1)
	
	if rand_side == 0:
		anim.play("SuckFromLeft")
	else:
		anim.play("SuckFromRight")
	
	await anim.animation_finished
	
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("gravel_cleaner: players_caught.size() = ", players_caught.size())
	pass

func _physics_process(delta):
	if !players_caught.is_empty():
		for p in players_caught:
			p.global_position.x = self.global_position.x
			p.global_position.y += -40
			
			if p.global_position.y <= -345:
				players_caught.remove_at(players_caught.find(p))

func _on_area_2d_body_entered(body):
	players_caught.append(body)

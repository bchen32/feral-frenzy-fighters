extends Node2D

@export var entry_pipe: bool = true
@export var dir_into_pipe: String = "LEFT"
@onready var teleport_point = self.get_node("Teleport")

var new_up_dir: Vector2
var reset_fall_grav_scale: float

# Called when the node enters the scene tree for the first time.
func _ready():
	if dir_into_pipe == "LEFT":
		new_up_dir = Vector2.LEFT
	elif dir_into_pipe == "RIGHT":
		new_up_dir = Vector2.RIGHT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	pass


func _on_area_2d_body_exited(body):
	pass

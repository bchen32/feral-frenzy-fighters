extends Node2D

@export var entry_pipe: bool = true
@export var connecting_pipe: Node2D
@onready var teleport = self.get_node("Teleport")
@onready var entry_particles = self.get_node("CPUParticles2DEntering")
@onready var exit_particles = self.get_node("CPUParticles2DExiting")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if entry_pipe == true:
		entry_particles.emitting = true
		exit_particles.emitting = false
	else:
		entry_particles.emitting = false
		exit_particles.emitting = true

func _on_teleport_body_entered(body):
	if entry_pipe == true:
		body.position = connecting_pipe.find_child("Teleport").global_position

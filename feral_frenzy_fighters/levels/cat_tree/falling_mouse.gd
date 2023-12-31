extends Node2D

class_name FallingMouse

#hitbox settings: line 25
var hitbox_scene: PackedScene = preload("res://player/attack/hitbox.tscn")
@onready var anim = get_node("AnimationPlayer")
@onready var mouse_sprite = get_node("MouseParent/Mouse")
@onready var mouse_sfx = get_node("MouseParent/MouseSFX")
@onready var vent_sfx = get_node("VentParent/VentSFX")
var mouse_is_falling = false

var event_network_data: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position.x = randi_range(500, 1500) # choose random x position
	self.position.y = -150
	
	var mouse_pitch_scale = randf_range(-.3, .3)
	var vent_pitch_scale = randf_range(0, .3)
	
	randomize()
	
	if NetworkManager.is_connected:
		self.position.x = event_network_data[0]
		mouse_pitch_scale = event_network_data[1]
		vent_pitch_scale = event_network_data[2]
	
	mouse_sfx.set_pitch_scale(vent_sfx.get_pitch_scale() + mouse_pitch_scale)
	vent_sfx.set_pitch_scale(vent_sfx.get_pitch_scale() + vent_pitch_scale)
	
	# Create a new hitbox
	var mouse_hitbox = hitbox_scene.instantiate()
	mouse_sprite.add_child(mouse_hitbox)
	
	#width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
	mouse_hitbox.setup(110, 50, -60, 40, 5, 1.25, 0, 0, false, self)
	
	mouse_sprite.visible = false
	
	vent_sfx.play()
	_animations()

func _physics_process(delta):
	vent_sfx.set_pitch_scale(vent_sfx.get_pitch_scale() - delta/10)
	if mouse_is_falling == true:
		mouse_sprite.rotate(3 * delta)
		mouse_sfx.set_pitch_scale(mouse_sfx.get_pitch_scale() - delta/10)
		

func _animations():
	anim.play("vent_falling") # plays vent_falling animation
	
	await anim.animation_finished
	
	mouse_sprite.visible = true
	vent_sfx.stop()
	mouse_sfx.play()
	anim.play("mouse_falling") # plays mouse_falling animation
	mouse_is_falling = true
	
	await anim.animation_finished
	
	queue_free() # deletes itself

extends Node2D

var broom_activated = false
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@onready var sprite = get_node("BroomSprite")
@onready var anim = get_node("AnimationPlayer")
@onready var sfx = get_node("BroomSFX")

func _ready():
	sprite.visible = false

func _physics_process(_delta):
	sfx.set_pitch_scale(sfx.get_pitch_scale() + _delta/10)
	
func _on_area_2d_body_entered(_body): # activate broom only when it's not already activated
	if _body is PlayerCharacter:
		if broom_activated == false:
			broom()

func broom():
	broom_activated = true # activate the broom event
	sprite.visible = true
	
	anim.play("broom_incoming") # plays broom_incoming animation
	anim.speed_scale = 1
	
	await anim.animation_finished # wait until broom_incoming animation finishes
	
	sprite.self_modulate = Color.WHITE
	
	# Create a new hitbox at the trigger area
	var broom_hitbox = hitbox_scene.instantiate()
	add_child(broom_hitbox)
	sfx.play()
	
	broom_hitbox.setup(205, 160, 0, 0, 20, 2, 0, 0)
	
	await get_tree().create_timer(0.1).timeout # wait amount of seconds
	
	# Find hitbox and remove it
	for child in get_children():
		if child is Hitbox:
			child.queue_free() 
	
	await get_tree().create_timer(1).timeout # wait amount of seconds
	
	anim.play_backwards("broom_incoming")
	anim.speed_scale = 4
	
	await anim.animation_finished # wait until broom_incoming animation finishes
	
	broom_activated = false # deactivate the broom event

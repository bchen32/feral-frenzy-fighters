extends Node2D

var x_positions = [250, 1670]
var facing_left = false
var shoot = false
var speed = 1000

var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@onready var sprite = self.get_child(0)
@onready var anim = self.get_child(1)
@onready var mouth = self.get_node("Sprite2D/Mouth")
@onready var aim = self.get_node("Sprite2D/Mouth/Aim")
@onready var hairball = self.get_node("Sprite2D/Mouth/Hairball")
@onready var cat_sfx = self.get_node("Sprite2D/HairballCatSFX")
@onready var hairball_sfx = self.get_node("Sprite2D/Mouth/Hairball/HairballSFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	hairball.visible = false
	
	# Choose random set x position for sprite, and flip horizontally to look towards middle
	sprite.position.x = x_positions.pick_random()
	self.position.y = 1500
	
	if sprite.position.x == x_positions[1]:
		sprite.flip_h = true
		mouth.position.x *= -1
		aim.position.x *= -1
		facing_left = true
	
	anim.play("coming_in")
	
	await anim.animation_finished
	await get_tree().create_timer(randi_range(1, 5)).timeout
	
	_shoot_hairball()

func _physics_process(delta):
	if shoot == true:
		hairball.visible = true
		hairball.position = hairball.position.move_toward(aim.position, speed * delta) # move hairball towards the aim point in the amount of seconds
		hairball.rotate(6 * delta)

func _shoot_hairball():
	anim.play("about_to_shoot")
	
	var angle = randf_range(-60, 0) # choose a random angle in perspective of facing right
	
	if facing_left == true: # flip angle if facing left
		angle *= -1
	
	mouth.rotation_degrees = angle
	
	await anim.animation_finished
	anim.play("shooting_hairball")
	
	# Create a new hitbox
	var hairball_hitbox = hitbox_scene.instantiate()
	hairball.add_child(hairball_hitbox)
	
	# (width, height, x_offset, y_offset, damage, knockback_scale, knockback_y_offset)
	hairball_hitbox.setup(70, 70, 0, 0, 10, 1.5, 0)
	
	shoot = true
	cat_sfx.set_pitch_scale(randf_range(1,1.5))
	cat_sfx.play()
	hairball_sfx.play()
	
	await anim.animation_finished
	anim.play_backwards("coming_in")
	await anim.animation_finished
	queue_free()

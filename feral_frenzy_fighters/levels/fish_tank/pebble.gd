extends RigidBody2D

var despawn_time = 1.0

#hitbox settings: line 84
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@onready var pebble_sprites = [
	load("res://levels/fish_tank/sprites/events/bigger_pebbles_hotpink.png"),
	load("res://levels/fish_tank/sprites/events/bigger_pebbles_pink.png"),
	load("res://levels/fish_tank/sprites/events/pebbles_hotpink.png"),
	load("res://levels/fish_tank/sprites/events/pebbles_pink.png")
]
@onready var sprite = get_node("Sprite2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = pebble_sprites.pick_random()
	
	# Create a new hitbox
	var pebble_hitbox = hitbox_scene.instantiate()
	self.add_child(pebble_hitbox)
	
	# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
	pebble_hitbox.setup(20, 20, 0, 0, 1, 1, 0, 0)

func _on_sleeping_state_changed():
	await get_tree().create_timer(despawn_time).timeout
	queue_free()

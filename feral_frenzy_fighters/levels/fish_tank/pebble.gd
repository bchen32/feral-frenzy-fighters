extends RigidBody2D

#hitbox settings: line 23
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
	self.linear_velocity = Vector2(0, 5)
	sprite.texture = pebble_sprites.pick_random()
	
	# Create a new hitbox
	var pebble_hitbox = hitbox_scene.instantiate()
	self.add_child(pebble_hitbox)
	
	# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
	pebble_hitbox.setup(20, 20, 0, 0, 2, 1.5, 0, 0)

func _process(delta):
	if linear_velocity.y <= 0.1:
		if self.get_child_count() > 2:
			self.get_child(2).queue_free()

func _on_sleeping_state_changed():
	await get_tree().create_timer(1).timeout
	queue_free()

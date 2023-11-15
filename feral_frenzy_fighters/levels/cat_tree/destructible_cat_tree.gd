extends Interactable

signal cat_tree_destroyed

@export var starting_health: int
@export var respawn_time: float
@export var destructible: bool = true
@onready var anim: AnimationPlayer = self.get_node("AnimationPlayer")
@onready var physical_collision: StaticBody2D = self.get_node("Physical")
@onready var hitbox: Area2D = self.get_node("Hitbox")
@onready var light_occluder: LightOccluder2D = self.get_node("LightOccluder2D")

var destroyed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = starting_health
	
	NetworkManager.env_hit_acked.connect(_on_env_hit_acked)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.health <= 0 && destroyed == false && destructible:
		_destroy_self()
		destroyed = true

func _on_env_hit_acked(env_part: String, health_change: int):
	var env_part_name: String = name
	
	if env_part_name == env_part:
		_change_health(health_change)

func _change_health(health_change: float):
	if !destructible:
		return
	
	self.health += health_change
	if anim.is_playing():
		anim.stop()
	
	if self.health > 0:
		anim.play("Damage")
		await anim.animation_finished
		if !hitbox.get_overlapping_bodies().is_empty():
			anim.play("Indication")

func _destroy_self():
	physical_collision.get_child(0).set_deferred("disabled", true)
	hitbox.get_child(0).set_deferred("disabled", true)
	light_occluder.visible = false
	
	cat_tree_destroyed.emit()
	
	anim.speed_scale = 1.25
	anim.play("Falling")
	await anim.animation_finished
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn():
	anim.play("Respawning")
	await anim.animation_finished
	anim.play("RESET")
	physical_collision.get_child(0).set_deferred("disabled", false)
	hitbox.get_child(0).set_deferred("disabled", false)
	light_occluder.visible = true
	
	self.health = starting_health
	destroyed = false

func _on_hitbox_body_entered(body):
	if destroyed == false and destructible:
		anim.play("Indication")

func _on_hitbox_body_exited(body):
	if destroyed == false:
		if hitbox.get_overlapping_bodies().is_empty():
			anim.play("RESET")

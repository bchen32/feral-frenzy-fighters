extends Interactable

@export var starting_health: int
var destroyed = false
@onready var anim = self.get_node("AnimationPlayer")
@onready var physical_collision = self.get_node("Physical")
@onready var hitbox = self.get_node("Hitbox")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = starting_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.health <= 0 && destroyed == false:
		_destroy_self()
		destroyed = true

func _change_health(health_change: float):
	self.health += health_change
	anim.play("Damage")

func _destroy_self():
	physical_collision.queue_free()
	hitbox.queue_free()
	
	anim.speed_scale = 1.25
	anim.play("Falling")
	
	await anim.animation_finished
	
	self.queue_free()

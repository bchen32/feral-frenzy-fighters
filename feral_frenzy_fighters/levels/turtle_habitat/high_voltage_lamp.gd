extends Interactable

var hit: bool = false
var players_in_area = []

@onready var hitbox: Area2D = get_node("Area2D")
@onready var collision_shape: CollisionShape2D = get_node("Area2D").get_child(0)
@onready var anim: AnimationPlayer = get_node("AnimationPlayer")
@onready var electric_particles: CPUParticles2D = get_node("ElectricParticles")
@onready var water_level = $"../../../Events/WaterLevel"
@onready var snap_spawner = $"../../../Events/SnappingSpawner"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = 30
	self.maxHealth = self.health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if water_level.water_level_state != 2 || self.health <= 0 || water_level.electrified == true:
		electric_particles.emitting = false
		collision_shape.disabled = true
		
		if self.health > 0: # if players didn't knock down lamp, health resets
			self.health = self.maxHealth
	elif water_level.water_level_state == 2 && self.health > 0: # high tide
		electric_particles.emitting = true
		collision_shape.disabled = false

func _change_health(health_change: float):
	self.health += health_change
	hit = true
	
	if anim.is_playing():
		anim.stop()
	
	if self.health > 0:
		if global_position.direction_to(players_in_area.front().global_position).x <= 0:
			anim.play("HitFromLeft")
		else:
			anim.play("HitFromRight")
		
		await anim.animation_finished
		hit = false
	elif self.health <= 0:
		anim.play("Fall")
		await get_tree().create_timer(2.5).timeout
		water_level.electrified_water_level()
		snap_spawner.kill_all()
		await anim.animation_finished
		queue_free()


func _on_area_2d_body_entered(body):
	players_in_area.append(body)
	
	if hit == false:
		anim.play("Indication")


func _on_area_2d_body_exited(body):
	if anim.current_animation == "Indication" && hit == false:
		if hitbox.get_overlapping_bodies().is_empty():
			anim.play("RESET")

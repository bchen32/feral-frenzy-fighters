extends Interactable

enum Wall_Plant_States {UNSPROUTED, SPROUTED, BURSTED}
var wall_plant_state = Wall_Plant_States.UNSPROUTED

var bursted_length = 10
var damage_rate = 0.25

var gatekeep_damage = false

var SFX = [
	preload("res://levels/turtle_habitat/sfx/Pop.wav"),
	preload("res://levels/cat_tree/sfx/events/cat_spit.wav")
]

#hitbox settings: search "wall_plant_hitbox"
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@onready var anim = get_node("AnimationPlayer")
@onready var hitbox = get_node("Hitbox")
@onready var sprite = get_node("Sprite2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = 20
	self.maxHealth = self.health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _change_health(health_change: float):
	if wall_plant_state == Wall_Plant_States.SPROUTED && gatekeep_damage == false:
		if self.health > 0:
			self.health += health_change
			
			anim.play("Damage")
			await anim.animation_finished
			
			if !hitbox.get_overlapping_bodies().is_empty():
				anim.play("Indication")
		elif self.health <= 0:
			_change_state(2)
			# state doesn't change until AFTER anim = dmg can still happen after health <= 0, so gatekeep bool implemented
			gatekeep_damage = true

func _change_state(index_state_to_change_to: int):
	# animation plays first
	var anim_to_play: String
	
	match index_state_to_change_to:
		0:
			anim_to_play = "Unsprouting"
		1:
			anim_to_play = "Sprouting"
		2:
			anim_to_play = "Bursting"
	anim.play(anim_to_play)
	await anim.animation_finished
	
	wall_plant_state = index_state_to_change_to
	
	# state function
	match wall_plant_state:
		Wall_Plant_States.UNSPROUTED: # called when BURSTED length finishes
			pass
		Wall_Plant_States.SPROUTED: # called when wall_plant_sprouter chooses this plant
			self.health = self.maxHealth
			gatekeep_damage = false
			$WallPlantSFX.stream = SFX[0]
			$WallPlantSFX.play()
		Wall_Plant_States.BURSTED: # called when health reaches 0 from SPROUTED
			reset_hitbox()
			await get_tree().create_timer(bursted_length).timeout
			_change_state(0)

func reset_hitbox(): # wall plant has a "poison" effect, so it keeps resetting hitbox so players in it keep taking damage
	if !sprite.get_children().is_empty():
		sprite.get_child(0).queue_free()
	
	if wall_plant_state == Wall_Plant_States.BURSTED:
		var wall_plant_hitbox = hitbox_scene.instantiate()
		sprite.add_child(wall_plant_hitbox)
		
		# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
		wall_plant_hitbox.setup(80, 80, 0, 0, 2, 0.5, 0, 0)
		
		await get_tree().create_timer(damage_rate).timeout
		reset_hitbox()

func _on_hitbox_body_entered(body):
	if wall_plant_state == Wall_Plant_States.SPROUTED && gatekeep_damage == false:
		anim.play("Indication")


func _on_hitbox_body_exited(body):
	if wall_plant_state == Wall_Plant_States.SPROUTED && gatekeep_damage == false:
		if hitbox.get_overlapping_bodies().is_empty():
			anim.play("KeepSprouted")

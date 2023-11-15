extends Node2D

enum Water_Level_States {LOWTIDE, LOWTOHIGH, HIGHTIDE, HIGHTOLOW}
var water_level_state = Water_Level_States.LOWTIDE

var max_high_tide_delay = 30
var min_high_tide_delay = 20
var high_tide_duration = 30

var electrified = false
var electric_dmg_rate = 1

var log_low_tide_pos: Vector2 = Vector2(1400, 620)

#hitbox settings: search "water_level_hitbox"
var hitbox_scene: PackedScene = preload("res://player/hitbox.tscn")
@onready var anim: AnimationPlayer = get_node("AnimationPlayer")
@onready var event_spawner = $"../EventSpawner"
@onready var electric_particles: CPUParticles2D = get_node("ElectricParticles")
@onready var ceiling_lamps = $"../../Interactables/CeilingLamps"
@onready var log_sprite: Sprite2D = get_node("Log")

# Called when the node enters the scene tree for the first time.
func _ready():
	if NetworkManager.is_connected:
		# TODO(Bobby): why do we need this so it sends send_env_data to both peers?
		await get_tree().create_timer(1).timeout
	
	NetworkManager.on_send_env_data.connect(_on_send_env_data)
	
	water_level_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if event_spawner.start_external_event == true: # will only happen after water_level called event_spawner's _external_event()
		water_level_state = Water_Level_States.LOWTOHIGH
		water_level_process()
		event_spawner.start_external_event = false
	Globals.water_level = self.global_position.y
	log_process()

func _on_send_env_data(event_name: String, event_data: Array):
	if event_name == "water_level":
		print("got water level")
		$WaterLevelTimer.start(event_data[0])

func water_level_process():
	match water_level_state:
		Water_Level_States.LOWTIDE:
			anim.play("LowTide")
			
			if NetworkManager.is_connected:
				print("requesting water level")
				NetworkManager.get_env_data.rpc("water_level")
			else:
				$WaterLevelTimer.start(randi_range(20, max_high_tide_delay))
		Water_Level_States.LOWTOHIGH:
			anim.stop()
			anim.play("Transition")
			await anim.animation_finished
			
			water_level_state = Water_Level_States.HIGHTIDE
			water_level_process()
		Water_Level_States.HIGHTIDE:
			anim.play("HighTide")
			await get_tree().create_timer(high_tide_duration).timeout
			
			water_level_state = Water_Level_States.HIGHTOLOW
			water_level_process()
		Water_Level_States.HIGHTOLOW:
			anim.stop()
			anim.play_backwards("Transition")
			await anim.animation_finished
			
			event_spawner._external_event(true) # tell event_spawner water_level event has finished
			water_level_state = Water_Level_States.LOWTIDE
			water_level_process()

func electrified_water_level():
	if !electric_particles.get_children().is_empty():
			electric_particles.get_child(0).queue_free()
	
	if water_level_state == Water_Level_States.HIGHTIDE:
		electrified = true
		electric_particles.emitting = true
		
		var water_level_hitbox = hitbox_scene.instantiate()
		electric_particles.add_child(water_level_hitbox)
		
		# width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset
		water_level_hitbox.setup(1350, 400, 0, -50, 25, 2, 0, 0)
		
		await get_tree().create_timer(electric_dmg_rate).timeout
		electrified_water_level()
	else:
		electrified = false
		electric_particles.emitting = false

func log_process():
	match water_level_state:
		Water_Level_States.LOWTIDE:
			log_sprite.global_position = log_low_tide_pos
			
		Water_Level_States.LOWTOHIGH:
			
			if self.global_position.y > log_low_tide_pos.y:
				log_sprite.global_position = log_low_tide_pos
			elif self.global_position.y <= log_low_tide_pos.y:
				log_sprite.global_position = Vector2(log_low_tide_pos.x, self.global_position.y)
			
		Water_Level_States.HIGHTIDE:
			log_sprite.global_position = Vector2(log_low_tide_pos.x, self.global_position.y)
			
		Water_Level_States.HIGHTOLOW:
			
			if self.global_position.y > log_low_tide_pos.y:
				log_sprite.global_position = log_low_tide_pos
			elif self.global_position.y <= log_low_tide_pos.y:
				log_sprite.global_position = Vector2(log_low_tide_pos.x, self.global_position.y)

func _on_water_level_timer_timeout():
	print("water_level: hey, event_spawner, I want to go next!")
	event_spawner._external_event(false) # tell event_spawner water_level event wants to start next time


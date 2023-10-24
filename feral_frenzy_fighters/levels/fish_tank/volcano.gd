extends Node2D

enum Volcano_States {DORMANT, ACTIVE, ERUPTING}
var volcano_state = Volcano_States.DORMANT

var active_max_delay = 30
var active_min_delay = 20
var erupt_max_delay = 30
var erupt_min_delay = 20

var pebble_amount = 100
var spawn_area_width = 1550
var spawn_area_height = -5000
var spawn_area_y_offset = -1600

@onready var anim = get_node("AnimationPlayer")
@onready var pebble_spawn = get_node("PebbleSpawn")
@onready var event_spawner = $"../EventSpawner"
@onready var full_shader = $"../../FullscreenShader"
var pebble = preload("res://levels/fish_tank/pebble.tscn")

var shader_tint = Vector4(0, 0, 0, -1)
var new_shader_tint = Vector4(0, 0, 0, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	_volcano_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if event_spawner.start_external_event == true: # will only happen after volcano called event_spawner's _external_event()
		volcano_state = Volcano_States.ERUPTING
		_volcano_process()
		event_spawner.start_external_event = false
	
	if shader_tint.distance_to(new_shader_tint) >= 0.1:
		shader_tint = lerp(shader_tint, new_shader_tint, delta)
		full_shader.material.set_shader_parameter("tint", shader_tint)

func _volcano_process():
	match volcano_state:
		Volcano_States.DORMANT:
			print("Volcano is DORMANT.")
			new_shader_tint = Vector4(0, 0, 0, -1)
			anim.play("RESET")
			await get_tree().create_timer(randi_range(active_min_delay, active_max_delay)).timeout
			
			volcano_state = Volcano_States.ACTIVE
			_volcano_process()
		Volcano_States.ACTIVE:
			print("Volcano is ACTIVE.")
			anim.play("Active")
			await get_tree().create_timer(randi_range(erupt_min_delay, erupt_max_delay)).timeout
			
			event_spawner._external_event(false) # tell event_spawner volcano event wants to start next time
		Volcano_States.ERUPTING:
			print("Volcano is ERUPTING.")
			new_shader_tint = Vector4(2, 0, 0, 0)
			await get_tree().create_timer(1).timeout
			anim.play("Eruption")
			await get_tree().create_timer(0.5).timeout
			
			for p in pebble_amount:
				var rand_x = randf_range(-spawn_area_width / 2, spawn_area_width / 2)
				var rand_y = randf_range(spawn_area_y_offset, spawn_area_y_offset + spawn_area_height)
				var new_pebble = pebble.instantiate()
				pebble_spawn.add_child(new_pebble)
				new_pebble.position = Vector2(rand_x, rand_y)
			
			await get_tree().create_timer(5).timeout
			event_spawner._external_event(true) # tell event_spawner volcano event has finished
			volcano_state = Volcano_States.DORMANT
			_volcano_process()

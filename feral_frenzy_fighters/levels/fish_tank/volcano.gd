extends Node2D

enum Volcano_States {DORMANT, ACTIVE, ERUPTING}
var volcano_state = Volcano_States.DORMANT

var active_max_delay = 30
var active_min_delay = 20
var erupt_max_delay = 30
var erupt_min_delay = 20

var pebble_amount = 70
var spawn_area_width = 1550
var spawn_area_height = -5000
var spawn_area_y_offset = -1600

@onready var anim = get_node("AnimationPlayer")
@onready var pebble_spawn = get_node("PebbleSpawn")
@onready var eruption_particles = get_node("EruptionParticles")
@onready var event_spawner = $"../EventSpawner"
@onready var timer = get_node("Timer")
var pebble = preload("res://levels/fish_tank/pebble.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_volcano_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if event_spawner.current_event_happening == false:
		timer.paused = false
	else:
		timer.paused = true

func _volcano_process():
	match volcano_state:
		Volcano_States.DORMANT:
			print("Volcano is DORMANT.")
			anim.play("RESET")
			timer.start(randi_range(active_min_delay, active_max_delay))
			await timer.timeout
			
			volcano_state = Volcano_States.ACTIVE
		Volcano_States.ACTIVE:
			print("Volcano is ACTIVE.")
			anim.play("Active")
			timer.start(randi_range(erupt_min_delay, erupt_max_delay))
			await timer.timeout
			
			volcano_state = Volcano_States.ERUPTING
		Volcano_States.ERUPTING:
			print("Volcano is ERUPTING.")
			anim.play("Erupting")
			eruption_particles.emitting = true
			await get_tree().create_timer(eruption_particles.lifetime).timeout
			
			for p in pebble_amount:
				var rand_x = randf_range(-spawn_area_width / 2, spawn_area_width / 2)
				var rand_y = randf_range(spawn_area_y_offset, spawn_area_y_offset + spawn_area_height)
				var new_pebble = pebble.instantiate()
				pebble_spawn.add_child(new_pebble)
				new_pebble.position = Vector2(rand_x, rand_y)
			
			await get_tree().create_timer(5).timeout
			volcano_state = Volcano_States.DORMANT
	_volcano_process()

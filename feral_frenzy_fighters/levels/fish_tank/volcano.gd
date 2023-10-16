extends Node2D

enum Volcano_States {DORMANT, ACTIVE, ERUPTING}
var volcano_state = Volcano_States.DORMANT

var active_max_delay = 30
var active_min_delay = 15
var active_delay: float
var erupt_max_delay = 30
var erupt_min_delay = 15
var erupt_delay: float

var num = 0

var pebble_amount = 40
var spawn_area_width = 1450
var spawn_area_height = 1000
var spawn_area_y_offset = -1600

@onready var sprite = get_node("Sprite2D")
@onready var pebble_spawn = get_node("PebbleSpawn")
@onready var active_particles = get_node("ActiveParticles")
@onready var eruption_particles = get_node("EruptionParticles")
@onready var event_spawner = $"../EventSpawner"
var pebble = preload("res://levels/fish_tank/pebble.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	_volcano_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _volcano_process():
	match volcano_state:
		Volcano_States.DORMANT:
			print("Volcano is DORMANT.")
			eruption_particles.emitting = false
		Volcano_States.ACTIVE:
			print("Volcano is ACTIVE.")
			active_particles.emitting = true
		Volcano_States.ERUPTING:
			print("Volcano is ERUPTING.")
			active_particles.emitting = false
			eruption_particles.emitting = true
	
	await get_tree().create_timer(3).timeout
	
	num += 1
	if num > 2:
		num = 0
	
	match num:
		0:
			volcano_state = Volcano_States.DORMANT
		1:
			volcano_state = Volcano_States.ACTIVE
		2:
			volcano_state = Volcano_States.ERUPTING
	
	_volcano_process()

func _eruption():
	pass

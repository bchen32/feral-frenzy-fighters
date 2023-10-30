extends Node2D

enum Water_Level_States {LOWTIDE, LOWTOHIGH, HIGHTIDE, HIGHTOLOW}
var water_level_state = Water_Level_States.LOWTIDE

var max_high_tide_delay = 30
var min_high_tide_delay = 20
var high_tide_duration = 15

@onready var anim = get_node("AnimationPlayer")
@onready var event_spawner = $"../EventSpawner"

# Called when the node enters the scene tree for the first time.
func _ready():
	water_level_process()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if event_spawner.start_external_event == true: # will only happen after volcano called event_spawner's _external_event()
		water_level_state = Water_Level_States.LOWTOHIGH
		water_level_process()
		event_spawner.start_external_event = false

func water_level_process():
	match water_level_state:
		Water_Level_States.LOWTIDE:
			pass
		Water_Level_States.LOWTOHIGH:
			pass
		Water_Level_States.HIGHTIDE:
			pass
		Water_Level_States.HIGHTOLOW:
			pass

extends Node2D

enum Water_Level_States {LOWTIDE, LOWTOHIGH, HIGHTIDE, HIGHTOLOW}
var water_level_state = Water_Level_States.LOWTIDE

var max_high_tide_delay = 5#30
var min_high_tide_delay = 5#20
var high_tide_duration = 30

@onready var anim = get_node("AnimationPlayer")
@onready var event_spawner = $"../EventSpawner"

# Called when the node enters the scene tree for the first time.
func _ready():
	water_level_process()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if event_spawner.start_external_event == true: # will only happen after water_level called event_spawner's _external_event()
		water_level_state = Water_Level_States.LOWTOHIGH
		water_level_process()
		event_spawner.start_external_event = false

func water_level_process():
	match water_level_state:
		Water_Level_States.LOWTIDE:
			anim.play("LowTide")
			await get_tree().create_timer(randi_range(min_high_tide_delay, max_high_tide_delay)).timeout
			print("water_level: hey, event_spawner, I want to go next!")
			event_spawner._external_event(false) # tell event_spawner water_level event wants to start next time
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

extends Node2D

@export var event_array: Array[PackedScene]

var start_new_random_event = false # used to trigger new event once
var set_camera_overview = false # this is referenced BY the camera, not to the camera
var current_event_happening = false

var longest_event_rate = 20.0
var shortest_event_rate = 1.0
var current_event_rate: float
var progression_rate = 0.1 # percentage of how much event rate will progress each time an event concludes

func _ready():
	current_event_rate = longest_event_rate
	await get_tree().create_timer(current_event_rate).timeout
	start_new_random_event = true

func _process(_delta):
	if start_new_random_event == true:
		_choose_events()
		change_set_overview(true)
		current_event_happening = true
		start_new_random_event = false

func _choose_events():
	var chosen_event = event_array.pick_random()
	
	var current_event = chosen_event.instantiate()
	add_child(current_event)

func _on_child_exiting_tree(_node): # when a child exits the tree (meaning a spawned event has concluded)
	change_set_overview(false)
	current_event_happening = false
	
	if current_event_rate > shortest_event_rate:
		var rate_difference = ((longest_event_rate - shortest_event_rate) * progression_rate)
		print("event_spawner: Event Rate changed from: ", current_event_rate, " to ", current_event_rate - rate_difference)
		current_event_rate -= rate_difference
	
	await get_tree().create_timer(current_event_rate).timeout
	start_new_random_event = true
	pass

func change_set_overview(_change: bool):
	set_camera_overview = _change

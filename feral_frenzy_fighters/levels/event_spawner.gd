extends Node2D

@export var event_array: Array[PackedScene]

var start_new_random_event = false # used to trigger new event once
var set_camera_overview = false # this is referenced BY the camera, not to the camera
var current_event_happening = false
var insert_external_event = false # used to insert an external event to happen on countdown instead
var start_external_event = false # used to trigger external event once

var longest_event_rate = 20.0
var shortest_event_rate = 3.0
var current_event_rate: float
var progression_rate = 0.1 # percentage of how much event rate will progress each time an event concludes

func _ready():
	if NetworkManager.is_connected:
		current_event_rate = longest_event_rate
		countdown_new_event()

func _process(_delta):
	if start_new_random_event == true:
		change_set_overview(true)
		current_event_happening = true
		
		if insert_external_event == false:
			_choose_events()
		elif insert_external_event == true:
			start_external_event = true
		
		insert_external_event = false
		start_new_random_event = false

func _choose_events():
	var chosen_event = event_array.pick_random()
	
	var current_event = chosen_event.instantiate()
	add_child(current_event)

func _on_child_exiting_tree(_node): # when a child exits the tree (meaning a spawned event has concluded)
	change_set_overview(false)
	current_event_happening = false
	
	if !current_event_rate <= shortest_event_rate:
		var rate_difference = ((longest_event_rate - shortest_event_rate) * progression_rate)
		print("event_spawner: Event Rate changed from: ", current_event_rate, " to ", current_event_rate - rate_difference)
		current_event_rate -= rate_difference
	
	countdown_new_event()

func countdown_new_event():
	await get_tree().create_timer(current_event_rate).timeout
	
	start_new_random_event = true

func change_set_overview(_change: bool):
	set_camera_overview = _change

# function used if external event wants to occur synced with event_spawner timer, mainly for not-spawned events and happens in-between events
func _external_event(finished: bool):
	if finished == false: # external event wants to start on next event
		insert_external_event = true
		print("event_spawner: external event has been inserted.")
	elif finished == true: # external event has finished
		countdown_new_event()
		print("event_spawner: external event has finished. Restarting countdown.")

extends Node2D

@export var event_array: Array[PackedScene]

var start_new_random_event = false # used to trigger new event once
var set_camera_overview = false # this is referenced BY the camera, not to the camera
var current_event_happening = false # used to actively detect if current event is occurring

func _ready():
	await get_tree().create_timer(3).timeout
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
	await get_tree().create_timer(randi_range(3, 8)).timeout
	start_new_random_event = true
	pass

func change_set_overview(_change: bool):
	set_camera_overview = _change

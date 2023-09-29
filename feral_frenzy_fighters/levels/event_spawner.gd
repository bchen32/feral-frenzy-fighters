extends Node2D

@onready var event_array = [preload("res://levels/cat_tree/falling_mouse.tscn"), preload("res://levels/cat_tree/hairball_cat.tscn")]

var start_new_random_event = false
@export var set_camera_overview = false # this is referenced BY the camera, not to the camera
@onready var plasma_ball = $"../../Interactables/PlasmaBall"

func _ready():
	await get_tree().create_timer(1).timeout
	start_new_random_event = true

func _process(_delta):
	if start_new_random_event == true:
		_choose_events()
		set_camera_overview = true
		start_new_random_event = false
	
	if plasma_ball.unstable == true:
		set_camera_overview = true
	elif plasma_ball.unstable == false && get_child_count() < 1:
		set_camera_overview = false

func _choose_events():
	var chosen_event = event_array.pick_random()
	
	var current_event = chosen_event.instantiate()
	add_child(current_event)

func _on_child_exiting_tree(_node): # when a child exits the tree (meaning an spawned event has concluded)
	set_camera_overview = false
	await get_tree().create_timer(randi_range(3, 8)).timeout
	start_new_random_event = true
	pass

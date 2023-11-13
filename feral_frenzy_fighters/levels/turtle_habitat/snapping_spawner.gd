extends Node2D

var turtle_amount = 4
var high_tide_duration: float
var waiting_on_high_tide = true
var x_spawn_points = [-200, 2200]
var players = []
var submerged_players = []

@onready var snap_turtle = preload("res://levels/turtle_habitat/snapping_turtle.tscn")
@onready var event_spawner = $"../EventSpawner"
@onready var water_level = $"../WaterLevel"

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkManager.on_send_env_data.connect(_on_send_env_data)
	
	players.append_array(get_tree().get_nodes_in_group("players"))
	high_tide_duration = water_level.high_tide_duration - 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if waiting_on_high_tide == true:
		if water_level.water_level_state == 2: # high tide
			if NetworkManager.is_connected:
				NetworkManager.get_env_data.rpc("snapping_manager")
			else:
				snapping_manager()
			waiting_on_high_tide = false
	elif waiting_on_high_tide == false:
		for p in players: # snapping turtles will only track players in submerged_players[]
			if !submerged_players.has(p) && p.global_position.y >= 400:
				submerged_players.append(p)
			elif submerged_players.has(p) && p.global_position.y < 400:
				submerged_players.remove_at(submerged_players.find(p))
		
		if water_level.water_level_state != 2:
			submerged_players.clear()
			waiting_on_high_tide = true

func _on_send_env_data(event_string: String, event_data: Array):
	if event_string == "snapping_manager":
		for turtle_pos in event_data:
			var new_turtle = snap_turtle.instantiate()
			new_turtle.global_position = turtle_pos
			self.add_child(new_turtle)

func snapping_manager():
	# spawning
	for t in turtle_amount:
		var new_turtle = snap_turtle.instantiate()
		new_turtle.global_position = Vector2(x_spawn_points.pick_random(), randi_range(560, 920))
		self.add_child(new_turtle)
	
	# life
	await get_tree().create_timer(high_tide_duration).timeout
	kill_all()

func kill_all():
	# death
	if !self.get_children().is_empty():
		for t in self.get_children():
			t.death()

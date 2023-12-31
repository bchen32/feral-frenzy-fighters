extends Node2D

var min_sprout_time = 3
var max_sprout_time = 7

var max_plants_sprouted = 4
var total_array = []

var unsprouted_array = []
var sprouted_array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	total_array.append_array(self.get_children())
	unsprouted_array.append_array(self.get_children())
	
	NetworkManager.on_send_env_data.connect(_on_send_env_data)
	
	if NetworkManager.is_connected:
		# TODO(Bobby): why do we need this so it sends send_env_data to both peers?
		await get_tree().create_timer(1).timeout
		NetworkManager.get_env_data.rpc("sprouting_cycle")
	else:
		sprouting_cycle([])

func _on_send_env_data(env_name: String, env_data: Array):
	if env_name == "sprouting_cycle":
		sprouting_cycle(env_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if sprouted_array.any(func(plant): return plant.wall_plant_state == 0): # checks to see if any plants in sprouted_array have become UNSPROUTED
		var unsprouted_plant = sprouted_array.filter(func(plant): return plant.wall_plant_state == 0).front()
		_update_sprout_arrays(unsprouted_plant, false)

func sprouting_cycle(env_data: Array):
	if env_data.is_empty():
		return
	
	print("env data length is %s" % env_data.size())
	
	var delay_time: int = env_data[0] if NetworkManager.is_connected else randi_range(min_sprout_time, max_sprout_time)
	
	await get_tree().create_timer(delay_time).timeout
	
	if sprouted_array.size() < max_plants_sprouted:
		var sprouting_plant = total_array[env_data[1]] if NetworkManager.is_connected else unsprouted_array.pick_random()
		sprouting_plant._change_state(1)
		_update_sprout_arrays(sprouting_plant, true)
	
	sprouting_cycle(env_data.slice(2) if NetworkManager.is_connected else env_data)

func _update_sprout_arrays(plant_to_update: Node2D, sprouting: bool):
	if sprouting == true:
		await plant_to_update.anim.animation_finished
		unsprouted_array.remove_at(unsprouted_array.find(plant_to_update))
		sprouted_array.append(plant_to_update)
	else:
		sprouted_array.remove_at(sprouted_array.find(plant_to_update))
		unsprouted_array.append(plant_to_update)
	
	print("wall_plant_sprouter: sprouted_array = ", sprouted_array.size(), " | unsprouted_array = ", unsprouted_array.size())

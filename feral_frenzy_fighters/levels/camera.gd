extends Camera2D

var player_1
var player_2

var overview_mode = false

var event_spawner
var original_position

func _ready():
	player_1 = $"../Player"
	player_2 = $"../Player2"
	event_spawner = $"../CatTreeLevel".get_node("DynamicObjects/MultiplayerSpawner/Events/EventSpawner")
	original_position = self.global_position

func _process(delta):
	overview_mode = event_spawner.set_camera_overview

func _physics_process(delta):
	if overview_mode == false and player_2 != null:
		self.global_position = self.global_position.move_toward((player_1.global_position + player_2.global_position) * 0.5, 5)
		var zoom_speed = 0.01
		
		var zoom_factor_1 = abs(player_1.global_position.x - player_2.global_position.x)/(1920-500)
		var zoom_factor_2 = abs(player_1.global_position.y - player_2.global_position.y)/(1080-500)
		var zoom_factor = max(max(zoom_factor_1, zoom_factor_2), 0.6)
		
		#print("Camera2D: zoom_factor_1 = ", zoom_factor_1, " | zoom_factor_2 = ", zoom_factor_2, " | zoom_factor = ", zoom_factor)
		
		if zoom_factor > 1:
			zoom_factor = 1
		
		self.zoom = Vector2(1 / zoom_factor, 1 / zoom_factor)
	elif overview_mode == true or player_2 == null:
		self.global_position = self.global_position.move_toward(original_position, 5)
		var zoom_speed = 0.01
		
		if self.zoom.x < 0.95:
			self.zoom.x += zoom_speed
		elif self.zoom.x > 1.00:
			self.zoom.x -= zoom_speed
		
		if self.zoom.y < 0.95:
			self.zoom.y += zoom_speed
		elif self.zoom.y > 1.00:
			self.zoom.y -= zoom_speed

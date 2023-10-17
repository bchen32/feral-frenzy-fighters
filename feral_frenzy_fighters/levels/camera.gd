extends Camera2D

@export var players: Array[Node] = []
@export var level: Node
@export var pos_duration: float = 0.5
@export var zoom_duration: float = 0.5
@export var max_zoom: float = 1.5
@export var margin: Vector2 = Vector2(800.0, 800.0)

var event_spawner: Node
var target_zoom: float
var initial_pos: Vector2
var target_pos: Vector2

func _ready():
	event_spawner = level.get_node("Events/EventSpawner")
	initial_pos = position
	target_pos = position
	target_zoom = zoom.x

func _process(_delta):
	if event_spawner.set_camera_overview or len(players) == 1:
		target_pos = initial_pos
		target_zoom = 1.0
	else:
		target_pos = (players[0].position + players[1].position) / 2
		var zoom_x = (get_viewport().get_visible_rect().size.x - margin.x) / (abs(players[1].position.x - players[0].position.x))
		var zoom_y = (get_viewport().get_visible_rect().size.y - margin.y) / (abs(players[1].position.y - players[0].position.y))
		target_zoom = max(min(zoom_x, zoom_y, max_zoom), 1)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", target_pos, pos_duration)
	tween.tween_property(self, "zoom", Vector2(target_zoom, target_zoom), zoom_duration)

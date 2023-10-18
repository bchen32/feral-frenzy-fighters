extends Camera2D

@export var players: Array[Node] = []
@export var level: Node
@export var pos_speed_scale: float = 4.0
@export var zoom_in_speed_scale: float = 0.5
@export var zoom_out_speed_scale: float = 1.5
@export var target_zoom_speed: float = 2.0
@export var max_pos_speed: float = 800.0
@export var max_zoom_speed: float = 2.0
@export var event_duration: float = 1.0
@export var min_zoom: float = 0.9
@export var max_zoom: float = 1.5
@export var margin: Vector2 = Vector2(400.0, 400.0)
@export var limit_margins: Vector2 = Vector2(200.0, 100.0)

var event_spawner: Node
var viewport_rect: Rect2
var initial_pos: Vector2
var old_target_zoom: float


func _ready():
	event_spawner = level.get_node("Events/EventSpawner")
	viewport_rect = get_viewport().get_visible_rect()
	initial_pos = position
	old_target_zoom = zoom.x

func _process(delta):
	if (event_spawner != null and event_spawner.set_camera_overview) or len(players) == 1:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "position", initial_pos, event_duration)
		tween.tween_property(self, "zoom", Vector2(1.0, 1.0), event_duration)
	else:
		var zoom_x = (viewport_rect.size.x - 2 * margin.x) / (abs(players[1].position.x - players[0].position.x))
		var zoom_y = (viewport_rect.size.y - 2 * margin.y) / (abs(players[1].position.y - players[0].position.y))
		var target_zoom = move_toward(old_target_zoom, max(min(zoom_x, zoom_y, max_zoom), min_zoom), target_zoom_speed * delta)
		old_target_zoom = target_zoom
		var target_zoom_vect = Vector2(target_zoom, target_zoom)
		var is_falling = players[0].velocity.y > 0 or players[1].velocity.y > 0
		var fall_speed_mult = 1.0
		if is_falling:
			var fall_speed = max(players[0].velocity.y, players[1].velocity.y)
			var terminal = min(players[0].terminal_vel, players[1].terminal_vel)
			fall_speed_mult = (fall_speed / terminal) + 1.0			
		var zoom_dist = zoom.distance_to(target_zoom_vect)
		var zoom_speed = min((zoom_in_speed_scale if target_zoom >= zoom.x else zoom_out_speed_scale) * zoom_dist, max_zoom_speed)
		zoom = zoom.move_toward(target_zoom_vect, (fall_speed_mult if is_falling and target_zoom < zoom.x else 1.0) * zoom_speed * delta)
		
		var target_pos = (players[0].position + players[1].position) / 2
		var clamped_pos = target_pos.clamp(viewport_rect.position + (viewport_rect.size / (2 * target_zoom)) - limit_margins,
								viewport_rect.end - (viewport_rect.size / (2 * target_zoom)) + limit_margins)
		var pos_dist = position.distance_to(clamped_pos)
		var pos_diff = (target_pos - position).normalized()
		var pos_speed = min(pos_speed_scale * pos_dist, max_pos_speed)
		var pos_speed_x = abs(pos_speed * pos_diff.x)
		var pos_speed_y = abs(pos_speed * pos_diff.y)
		position.x = move_toward(position.x, target_pos.x, pos_speed_x * delta)
		position.y = move_toward(position.y, target_pos.y, (fall_speed_mult if is_falling else 1.0) * pos_speed_y * delta)
		position = position.clamp(viewport_rect.position + (viewport_rect.size / (2 * zoom)) - limit_margins,
								viewport_rect.end - (viewport_rect.size / (2 * zoom)) + limit_margins)

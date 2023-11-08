extends TextureRect

class_name ArrowDirection

signal on_direction_changed

@export var right_position: Vector2 = Vector2(223, -87)
@export var up_down_position: Vector2 = Vector2(0, 0)
@export var target_area: GoalArea

enum Direction {
	INITIAL,
	LEFT,
	RIGHT,
	UP,
	DOWN
}

var current_direction: Direction = Direction.INITIAL
var _player: PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_area == null:
		hide()
		return
	
	var position_delta: Vector2 = target_area.global_position - _player.global_position
	
	if target_area.is_player_in_area or position_delta.length() < 100:
		hide()
		return
	else:
		show()
	
	var new_direction: Direction
	
	if abs(position_delta.x) > abs(position_delta.y):
		if position_delta.x > 0:
			# point LEFT
			new_direction = Direction.LEFT
			position = Vector2(right_position.x, right_position.y)
			rotation_degrees = 0
		else:
			# point RIGHT
			new_direction = Direction.RIGHT
			position = Vector2(-right_position.x, right_position.y)
			rotation_degrees = 180
	else:
		if position_delta.y > 0:
			# point UP
			new_direction = Direction.UP
			rotation_degrees = 90
			position = Vector2(20, -150)
		else:
			# point DOWN
			new_direction = Direction.DOWN
			rotation_degrees = 270
			position = Vector2(-40, -100)
	
	if current_direction != new_direction:
		current_direction = new_direction
		on_direction_changed.emit()

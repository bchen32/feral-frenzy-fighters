extends TextureRect

@export var right_position: Vector2 = Vector2(223, -87)
@export var up_down_position: Vector2 = Vector2(0, 0)
@export var target_area: GoalArea

var _player: PlayerCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = get_parent().get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_area == null or target_area.is_player_in_area:
		hide()
		return
	else:
		show()
	
	var position_delta: Vector2 = target_area.global_position - _player.global_position
	
	if abs(position_delta.x) > abs(position_delta.y):
		if position_delta.x > 0:
			# point RIGHT
			position = Vector2(-right_position.x, right_position.y)
			rotation_degrees = 180
		else:
			# point LEFT
			position = Vector2(right_position.x, right_position.y)
			rotation_degrees = 0
	else:
		if position_delta.y > 0:
			# point DOWN
			rotation_degrees = 270
			position = Vector2(-40, -100)
		else:
			# point UP
			rotation_degrees = 90
			position = Vector2(20, -150)

extends Area2D

class_name GoalArea

signal goal_area_fufilled

@export var active_goal_area: bool = false
@export var external_trigger_area: bool = false

var is_player_in_area: bool = false

var _past_active_goal_area: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _past_active_goal_area != active_goal_area:
		if active_goal_area:
			$AnimationPlayer.play("flicker")
			monitoring = true
		else:
			$AnimationPlayer.stop()
			monitoring = false
		
		_past_active_goal_area = active_goal_area

func _on_body_entered(body):
	if body is PlayerCharacter and not external_trigger_area:
		assert(not is_player_in_area)
		is_player_in_area = true
		
		goal_area_fufilled.emit()

func _on_body_exited(body):
	if body is PlayerCharacter and not external_trigger_area:
		assert(is_player_in_area)
		is_player_in_area = false

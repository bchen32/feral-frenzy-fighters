extends Node2D

@export var tutorial_billboard: Control

var _player_spawn_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_spawn_position = $Player.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var attack_goal_distance_vector: Vector2 = \
		($AttackGoalArea.global_position + Vector2(0, 196)) - $Player.global_position
	
	if $AttackGoalArea.active_goal_area and abs(attack_goal_distance_vector.length()) < 100:
		$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.ATTACK)


func _on_right_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = $TopGoalArea
	
	$RightGoalArea.active_goal_area = false
	$TopGoalArea.active_goal_area = true


func _on_top_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = $AttackGoalArea
	
	$TopGoalArea.active_goal_area = false
	$AttackGoalArea.active_goal_area = true


func _on_attack_goal_area_goal_area_fufilled():
	$Player2.show()
	$Player/DamageUI.show()
	
	$Player/Camera2D/ArrowDirection.target_area = $Player2/Player2GoalArea
	$AttackGoalArea.active_goal_area = false
	$Player2/Player2GoalArea.active_goal_area = true


func _on_cat_tree_left_cat_tree_destroyed():
	_on_attack_goal_area_goal_area_fufilled()


func _on_arrow_direction_on_direction_changed():
	match $Player/Camera2D/ArrowDirection.current_direction:
		ArrowDirection.Direction.RIGHT:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.WALK_LEFT)
		ArrowDirection.Direction.LEFT:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.WALK_RIGHT)
		ArrowDirection.Direction.UP:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.JUMP)
		ArrowDirection.Direction.DOWN:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.FALL)


func _on_dead_areas_body_entered(body):
	if body is CharacterBody2D:
		if body == $Player:
			$Player.position = _player_spawn_position
		else:
			assert(body == $Player2)
			
			# done with tutorial!
			print("done with tutorial!")

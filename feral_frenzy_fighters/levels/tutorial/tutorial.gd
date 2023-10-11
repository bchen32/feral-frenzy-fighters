extends Node2D

@export var tutorial_billboard: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_right_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = $TopGoalArea
	
	$RightGoalArea.active_goal_area = false
	$TopGoalArea.active_goal_area = true


func _on_top_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = $AttackGoalArea
	
	$TopGoalArea.active_goal_area = false
	$AttackGoalArea.active_goal_area = true


func _on_attack_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = null
	$AttackGoalArea.active_goal_area = false


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

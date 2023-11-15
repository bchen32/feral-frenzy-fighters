extends Node2D

@export var tutorial_billboard: Control

var _current_taunt_action: TutorialBillboard.TutorialAction = TutorialBillboard.TutorialAction.IDLE
var _player_spawn_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_spawn_position = $Player.position
	Globals.rebind_p1(0)
	Globals.water_level = 10000

func _input(event):
	if _current_taunt_action == TutorialBillboard.TutorialAction.THUMBS_UP and \
		event.is_action_pressed("p1_thumbs_up"):
		_current_taunt_action = TutorialBillboard.TutorialAction.SKULL
		$Player/TutorialBillboard.set_tutorial_action(_current_taunt_action)
	elif _current_taunt_action == TutorialBillboard.TutorialAction.THUMBS_DOWN and \
		 event.is_action_pressed("p1_thumbs_down"):
		_current_taunt_action = TutorialBillboard.TutorialAction.THUMBS_UP
		$Player/TutorialBillboard.set_tutorial_action(_current_taunt_action)
	elif _current_taunt_action == TutorialBillboard.TutorialAction.SKULL and \
		 event.is_action_pressed("p1_skull"):
		$Player/Camera2D/ArrowDirection.target_area = $Environment/AttackGoalArea
		
		$Environment/CatTreeLeft/DashGoalArea.active_goal_area = false
		$Environment/AttackGoalArea.active_goal_area = true
		
		$Environment/CatTreeLeft.destructible = true
		$Environment/CatTreeMiddle.destructible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var attack_goal_distance_vector: Vector2 = \
		($Environment/AttackGoalArea.global_position + Vector2(0, 400)) - $Player.global_position
	var player2_goal_distance_vector: Vector2 = \
		($Player2/Player2GoalArea.global_position) - $Player.global_position
	
	if ($Environment/AttackGoalArea.active_goal_area and abs(attack_goal_distance_vector.length()) < 100) or \
	   ($Player2/Player2GoalArea.active_goal_area and abs(player2_goal_distance_vector.length()) < 100):
		$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.ATTACK)
	
	if $Environment/CatTreeLeft/DashGoalArea.active_goal_area:
		var dash_goal = $Player.global_position.y - $Environment/CatTreeLeft/DashGoalArea.global_position.y
		if dash_goal > -400 and $Player/TutorialBillboard.current_tutorial_action == TutorialBillboard.TutorialAction.WALK_RIGHT:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.DASH)
		elif dash_goal <= -400 or $Player/TutorialBillboard.current_tutorial_action != TutorialBillboard.TutorialAction.DASH:
			_on_arrow_direction_on_direction_changed()

func _on_right_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = $Environment/CatTreeLeft/TopGoalArea
	
	$RightGoalArea.active_goal_area = false
	$Environment/CatTreeLeft/TopGoalArea.active_goal_area = true


func _on_top_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = $Environment/CatTreeLeft/DashGoalArea
	
	$Environment/CatTreeLeft/TopGoalArea.active_goal_area = false
	$Environment/CatTreeLeft/DashGoalArea.active_goal_area = true

func _on_dash_goal_area_goal_area_fufilled():
	$Player/Camera2D/ArrowDirection.target_area = null
	$Environment/CatTreeLeft/DashGoalArea.active_goal_area = false
	
	$Player/DamageUI.show()
	$Player/DamageUI.set_player_death_count(2, 1)
	
	$Player/DamageUI/P2.hide()
	
	_current_taunt_action = TutorialBillboard.TutorialAction.THUMBS_DOWN
	$Player/TutorialBillboard.set_tutorial_action(_current_taunt_action)

func _on_attack_goal_area_goal_area_fufilled():
	$Player2.show()
	$Player/DamageUI/P2.show()
	
	$Player/Camera2D/ArrowDirection.target_area = $Player2/Player2GoalArea
	$Environment/AttackGoalArea.active_goal_area = false
	$Player2/Player2GoalArea.active_goal_area = true
	$Player2.process_mode = Node.PROCESS_MODE_INHERIT


func _on_cat_tree_middle_cat_tree_destroyed():
	_on_attack_goal_area_goal_area_fufilled()


func _on_arrow_direction_on_direction_changed():
	match $Player/Camera2D/ArrowDirection.current_direction:
		ArrowDirection.Direction.RIGHT:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.WALK_LEFT)
		ArrowDirection.Direction.LEFT:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.WALK_RIGHT)
		ArrowDirection.Direction.DOWN:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.JUMP)
		ArrowDirection.Direction.UP:
			$Player/TutorialBillboard.set_tutorial_action(TutorialBillboard.TutorialAction.FALL)


func _on_dead_areas_body_entered(body):
	if body is CharacterBody2D:
		if body == $Player:
			$Player.position = _player_spawn_position
		else:
			assert(body == $Player2)
			
			get_tree().change_scene_to_file("res://gui/menus/title_screen.tscn")


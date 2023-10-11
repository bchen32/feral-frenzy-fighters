extends Control

class_name TutorialBillboard

enum TutorialAction {
	FALL,
	JUMP,
	IDLE,
	WALK_LEFT,
	WALK_RIGHT,
	ATTACK
}

var current_tutorial_action: TutorialAction

func _update_control_animations(tutorial_action: TutorialAction):
	var base_action_string: String = ""
	
	match tutorial_action:
		TutorialAction.FALL:
			base_action_string = "fall"
		TutorialAction.JUMP:
			base_action_string = "jump"
		TutorialAction.IDLE:
			hide()
			return
		TutorialAction.ATTACK:
			base_action_string = "attack"
		TutorialAction.WALK_LEFT:
			base_action_string = "left"
		TutorialAction.WALK_RIGHT:
			base_action_string = "right"
	
	$Control/VBoxContainer/Control/JoystickAnimation.play("joystick_" + base_action_string)
	$Control/VBoxContainer/Control2/P1Animation.play("p1_" + base_action_string)
	$Control/VBoxContainer/Control3/P2Animation.play("p2_" + base_action_string)

func set_tutorial_action(tutorial_action: TutorialAction):
	if tutorial_action == current_tutorial_action:
		return
	
	show()
	_update_control_animations(tutorial_action)
	
	match tutorial_action:
		TutorialAction.FALL:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_fall")
		TutorialAction.JUMP:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_jump")
		TutorialAction.IDLE:
			hide()
		TutorialAction.ATTACK:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_attack_neutral")
		TutorialAction.WALK_LEFT, TutorialAction.WALK_RIGHT:
			$Control/PlayerSprite/AnimatedSprite2D.flip_h = \
				tutorial_action == TutorialAction.WALK_RIGHT
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_walk")
	
	current_tutorial_action = tutorial_action

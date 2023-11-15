extends Control

class_name TutorialBillboard

enum TutorialAction {
	FALL,
	JUMP,
	IDLE,
	WALK_LEFT,
	WALK_RIGHT,
	ATTACK,
	DASH,
	THUMBS_DOWN,
	THUMBS_UP,
	SKULL
}

var current_tutorial_action: TutorialAction
@onready var context_label: Label = get_node("ContextLabel")

func _play_and_resize_animation(animated_sprite_2d: AnimatedSprite2D, current_animation: String):
	animated_sprite_2d.play(current_animation)
	
	var sprite_texture : Texture2D = animated_sprite_2d.sprite_frames.get_frame_texture(current_animation, 0)
	animated_sprite_2d.scale = Vector2(150, 150) / sprite_texture.get_size()

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
		TutorialAction.DASH:
			base_action_string = "dash"
		TutorialAction.THUMBS_DOWN:
			base_action_string = "thumbs_down"
		TutorialAction.THUMBS_UP:
			base_action_string = "thumbs_up"
		TutorialAction.SKULL:
			base_action_string = "skull"
	
	_play_and_resize_animation($Control/VBoxContainer/Control/JoystickAnimation, "joystick_" + base_action_string)
	_play_and_resize_animation($Control/VBoxContainer/Control2/P1Animation, "p1_" + base_action_string)
	_play_and_resize_animation($Control/VBoxContainer/Control3/P2Animation, "p2_" + base_action_string)

func set_tutorial_action(tutorial_action: TutorialAction):
	if tutorial_action == current_tutorial_action:
		return
	
	show()
	_update_control_animations(tutorial_action)
	
	if tutorial_action == TutorialAction.THUMBS_DOWN or \
	   tutorial_action == TutorialAction.THUMBS_UP or tutorial_action == TutorialAction.SKULL:
		$Control/PlayerSprite/AnimatedSprite2D.scale = Vector2(3, 3)
	else:
		$Control/PlayerSprite/AnimatedSprite2D.scale = Vector2(0.3, 0.3)
	
	match tutorial_action:
		TutorialAction.FALL:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_fall")
			context_label.text = "Movement:\nHold input to drop down!"
		TutorialAction.JUMP:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_jump")
			context_label.text = "Movement:\nHint: You can triple jump."
		TutorialAction.IDLE:
			hide()
		TutorialAction.ATTACK:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_attack_neutral")
			if $"../../Environment/AttackGoalArea".monitoring:
				context_label.text = "Environment:\nWatch for and hit highlighted stuff!"
			elif $"../../Player2/Player2GoalArea".monitoring:
				context_label.text = "Goal:\nKnock players out-of-bounds!"
		TutorialAction.WALK_LEFT, TutorialAction.WALK_RIGHT:
			$Control/PlayerSprite/AnimatedSprite2D.flip_h = \
				tutorial_action == TutorialAction.WALK_RIGHT
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_walk")
			context_label.text = "Movement:\nMove to the blinking area!"
		TutorialAction.DASH:
			$Control/PlayerSprite/AnimatedSprite2D.play("blue_dash")
			context_label.text = "Movement:\nHold shown input while moving to dash!"
		TutorialAction.THUMBS_DOWN:
			$Control/PlayerSprite/AnimatedSprite2D.play("tutorial_thumbs_down")
			context_label.text = "Taunting:\nPress inputs to emote! :("
		TutorialAction.THUMBS_UP:
			$Control/PlayerSprite/AnimatedSprite2D.play("tutorial_thumbs_up")
			context_label.text = "Taunting:\nPress inputs to emote! :)"
		TutorialAction.SKULL:
			$Control/PlayerSprite/AnimatedSprite2D.play("tutorial_skull")
			context_label.text = "Taunting:\nPress inputs to emote! X_x"
	
	current_tutorial_action = tutorial_action


func _on_animated_sprite_2d_animation_finished():
	$Control/PlayerSprite/AnimatedSprite2D.play($Control/PlayerSprite/AnimatedSprite2D.animation)

func _on_skip_tutorial_button_pressed():
	get_tree().change_scene_to_file("res://gui/menus/title_screen.tscn")

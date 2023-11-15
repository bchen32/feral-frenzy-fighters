extends Control

@onready var graybox = preload("res://gui/hud/sprites/stage_select_icons/random_select_stage.png")
@onready var bluebox = preload("res://gui/hud/sprites/stage_select_icons/playertwo_select_stage.png")
@onready var purplebox = preload("res://gui/hud/sprites/stage_select_icons/playerone_select_stage.png")

@onready var p1_selection = []
@onready var p1_stage = 0
@onready var p2_selection = []
@onready var p2_stage = 0
@onready var p1_locked = false
@onready var p2_locked = false
@onready var unlocked_transparency = .75
var ui

var actual_selection = []
var final_selection

# Called when the node enters the scene tree for the first time.
func _ready():
	if NetworkManager.is_connected:
		p1_locked = NetworkManager.my_player_num != 0
		p2_locked = NetworkManager.my_player_num != 1
		
		NetworkManager.character_stage_screen_change_acked.connect(_on_stage_screen_change_acked)
		NetworkManager.character_stage_screen_lock_in_acked.connect(_on_stage_screen_lock_in_acked)
		NetworkManager.on_stage_selected.connect(_on_stage_selected)
	
	show()
	
	for button in $Background/Player1ButtonsContainer/P1ButtonsTop.get_children():
		if button.is_visible():
			p1_selection.append(button)
			button.modulate.a = unlocked_transparency
			button.texture_normal = graybox
	for button in $Background/Player1ButtonsContainer/P1ButtonsBottom.get_children():
		if button.is_visible():
			p1_selection.append(button)
			button.modulate.a = unlocked_transparency
			button.texture_normal = graybox
	for button in $Background/Player2ButtonsContainer/P2ButtonsTop.get_children():
		if button.is_visible():
			p2_selection.append(button)
			button.modulate.a = unlocked_transparency
			button.texture_normal = graybox
	for button in $Background/Player2ButtonsContainer/P2ButtonsBottom.get_children():
		if button.is_visible():
			p2_selection.append(button)
			button.modulate.a = unlocked_transparency
			button.texture_normal = graybox

	p1_selection[0].texture_normal = purplebox
	p2_selection[0].texture_normal = bluebox

	ui = Menu.new($Background)
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(true)   

func is_action_just_pressed(player_num: int, action: String):
	if not NetworkManager.is_connected:
		return InputManager.is_action_just_pressed("p%s_%s" % [player_num, action])
	else:
		return InputManager.is_action_just_pressed("p1_%s" % action)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if InputManager.is_action_just_pressed("ui_back") and not NetworkManager.is_connected:
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
		else:
			become_inactive()
	
	if !p1_locked:
		if is_action_just_pressed(1, "left") or is_action_just_pressed(1, "ui_left"):
			if p1_stage <= 0:
				p1_selection[p1_stage].texture_normal = graybox
				p1_selection[len(p1_selection)-1].texture_normal = purplebox
				p1_stage = len(p1_selection)-1
				on_stage1_change()
			else:
				p1_selection[p1_stage].texture_normal = graybox
				p1_stage-=1
				p1_selection[p1_stage].texture_normal = purplebox
				on_stage1_change()
		if is_action_just_pressed(1, "right") or is_action_just_pressed(1, "ui_right"):
			if p1_stage >= len(p1_selection)-1:
				p1_selection[p1_stage].texture_normal = graybox
				p1_selection[0].texture_normal = purplebox
				p1_stage = 0
				on_stage1_change()
			else:
				p1_selection[p1_stage].texture_normal = graybox
				p1_stage+=1
				p1_selection[p1_stage].texture_normal = purplebox
				on_stage1_change()
				
		if is_action_just_pressed(1, "accept"):
			p1_locked = true
			p1_selection[p1_stage].modulate.a = 1
			actual_selection.append(p1_stage)
			on_locked_in()
				
	if !p2_locked:
		if is_action_just_pressed(2, "left") or is_action_just_pressed(2, "ui_left"):
			if p2_stage <= 0:
				p2_selection[p2_stage].texture_normal = graybox
				p2_selection[len(p2_selection)-1].texture_normal = bluebox
				p2_stage = len(p2_selection)-1
				on_stage2_change()
			else:
				p2_selection[p2_stage].texture_normal = graybox
				p2_stage-=1
				p2_selection[p2_stage].texture_normal = bluebox
				on_stage2_change()
		if is_action_just_pressed(2, "right") or is_action_just_pressed(2, "ui_right"):
			if p2_stage >= len(p2_selection)-1:
				p2_selection[p2_stage].texture_normal = graybox
				p2_selection[0].texture_normal = bluebox
				p2_stage = 0
				on_stage2_change()
			else:
				p2_selection[p2_stage].texture_normal = graybox
				p2_stage+=1
				p2_selection[p2_stage].texture_normal = bluebox
				on_stage2_change()
				
		if is_action_just_pressed(2, "accept"):
			p2_locked = true
			p2_selection[p2_stage].modulate.a = 1
			actual_selection.append(p2_stage)
			on_locked_in()
			

func become_inactive():
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(get_viewport().size.x,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(false)
	get_parent()._ready()
	await get_tree().create_timer(.5).timeout
	get_parent().set_process(true)
	queue_free()

func on_stage1_change(send_networked_response: bool = true):
	if send_networked_response and NetworkManager.is_connected:
		NetworkManager.character_stage_screen_character_change.rpc(p1_stage)
	
	$P1Sounds.play()

func on_stage2_change(send_networked_response: bool = true):
	if send_networked_response and NetworkManager.is_connected:
		NetworkManager.character_stage_screen_character_change.rpc(p2_stage)
	
	$P2Sounds.play()

func _on_stage_selected(stage_selected: int):
	var new_icon
	
	Globals.stage = stage_selected
	
	match stage_selected:
		0:
			new_icon = $Background/StageIconsContainer/StageIconsTop/CatStageIcon.duplicate()
			final_selection = 0
			animate_selection(new_icon)
			
		1:
			new_icon = $Background/StageIconsContainer/StageIconsTop/FishStageIcon.duplicate()
			final_selection = 1
			animate_selection(new_icon)
		2:
			new_icon = $Background/StageIconsContainer/StageIconsBottom/TurtleStageIcon.duplicate()
			final_selection = 2
			animate_selection(new_icon)

func on_locked_in():
	$MenuSound.play()
	if p1_locked and p2_locked and not NetworkManager.is_connected:
		self.set_process(false)
		randomize()
		var new_icon
		_on_stage_selected(actual_selection[randi() % actual_selection.size()])

func animate_selection(icon):
	icon.scale*=2
	
	add_child(icon)
	
	var viewport_center = Vector2(get_viewport().size.x/2,get_viewport().size.y/2)
	var icon_size = Vector2(icon.texture.get_width()*icon.scale.x,icon.texture.get_height()*icon.scale.y)
	
	icon.global_position = viewport_center-icon_size/2 + Vector2(0,get_viewport().size.y)
	
	var tween := create_tween()
	tween.tween_property(icon, "global_position", viewport_center-icon_size/2, .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(.5).timeout
	
	if NetworkManager.is_connected:
		NetworkManager.game_state_change_request.rpc(
			NetworkManager.NetworkGameState.IN_FIRST_CUTSCENE)
	else:
		go_to_stage()

func go_to_stage():
	Globals.stage = final_selection
	get_tree().change_scene_to_file("res://gui/menus/cutscene_player.tscn")

func _on_button_mouse_entered(extra_arg_0):
	if NetworkManager.is_connected and NetworkManager.my_player_num == 1 and !p2_locked:
		p2_selection[p2_stage].texture_normal = graybox
		p2_stage = extra_arg_0
		p2_selection[p2_stage].texture_normal = bluebox
		on_stage2_change()
	elif !p1_locked:
		p1_selection[p1_stage].texture_normal = graybox
		p1_stage = extra_arg_0
		p1_selection[p1_stage].texture_normal = purplebox
		on_stage1_change()

func _p1_lock_in():
	if NetworkManager.is_connected and NetworkManager.my_player_num == 1 and !p2_locked:
		p2_locked = true
		p2_selection[p2_stage].modulate.a = 1
		actual_selection.append(p2_stage)
	elif !p1_locked:
		p1_locked = true
		p1_selection[p1_stage].modulate.a = 1
		actual_selection.append(p1_stage)
	
	NetworkManager.character_stage_screen_lock_in.rpc()
	on_locked_in()

func _on_stage_screen_change_acked(player_num: int, stage: int):
	if player_num != NetworkManager.my_player_num:
		if player_num == 0:
			p1_selection[p1_stage].texture_normal = graybox
			p1_stage = stage
			p1_selection[p1_stage].texture_normal = purplebox
			on_stage1_change(false)
		else:
			p2_selection[p2_stage].texture_normal = graybox
			p2_stage = stage
			p2_selection[p2_stage].texture_normal = bluebox
			on_stage2_change(false)

func _on_stage_screen_lock_in_acked(player_num: int, stage: int):
	if player_num == 1:
		p1_selection[p1_stage].modulate.a = 1
	else:
		p2_selection[p2_stage].modulate.a = 1

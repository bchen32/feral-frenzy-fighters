extends Control

@onready var p1_portrait = $Background/PlayerPortraits/Player1Portrait
@onready var p2_portrait = $Background/PlayerPortraits/Player2Portrait
@onready var p2_stat = $Background/Player2Stats
@onready var p1_stat = $Background/Player1Stats
@onready var p1_text = $Background/Player1Text
@onready var p2_text = $Background/Player2Text

@onready var graybox = preload("res://gui/hud/sprites/cs_icons/selection_box.png")
@onready var bluebox = preload("res://gui/hud/sprites/cs_icons/playertwo_select_character.png")
@onready var purplebox = preload("res://gui/hud/sprites/cs_icons/playerone_select_character.png")

@onready var p1_selection = []
@onready var p1_character = 0
@onready var p2_selection = []
@onready var p2_character = 0
@onready var p1_locked = false
@onready var p2_locked = false

var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	if NetworkManager.is_connected:
		p1_locked = NetworkManager.my_player_num != 0
		p2_locked = NetworkManager.my_player_num != 1
		
		NetworkManager.character_stage_screen_change_acked.connect(_on_character_screen_change_acked)
		NetworkManager.character_stage_screen_lock_in_acked.connect(_on_character_screen_lock_in_acked)
	
	for button in $Background/P1Buttons.get_children():
		if button.is_visible():
			p1_selection.append(button)
			button.texture_normal = graybox
		
	for button in $Background/P2Buttons.get_children():
		if button.is_visible():
			p2_selection.append(button)
			button.texture_normal = graybox
			
	p1_selection[0].texture_normal = purplebox
	p2_selection[0].texture_normal = bluebox
	$Background/Player1Text/P1Ready.hide()
	$Background/Player2Text/P2Ready.hide()
	
	show()
	ui = Menu.new($Background)
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(true)   
	on_character1_change()
	on_character2_change()

func is_action_just_pressed(player_num: int, action: String):
	if not NetworkManager.is_connected:
		return InputManager.is_action_just_pressed("p%s_%s" % [player_num, action])
	else:
		return InputManager.is_action_just_pressed("p1_%s" % action)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not NetworkManager.is_connected and InputManager.is_action_just_pressed("ui_back"):
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
		else:
			become_inactive()
	if !p1_locked:
		if is_action_just_pressed(1, "left") or is_action_just_pressed(1, "ui_left"):
			if p1_character <= 0:
				p1_selection[p1_character].texture_normal = graybox
				p1_selection[len(p1_selection)-1].texture_normal = purplebox
				p1_character = len(p1_selection)-1
				on_character1_change()
			else:
				p1_selection[p1_character].texture_normal = graybox
				p1_character-=1
				p1_selection[p1_character].texture_normal = purplebox
				on_character1_change()
		if is_action_just_pressed(1, "right") or is_action_just_pressed(1, "ui_right"):
			if p1_character >= len(p1_selection)-1:
				p1_selection[p1_character].texture_normal = graybox
				p1_selection[0].texture_normal = purplebox
				p1_character = 0
				on_character1_change()
			else:
				p1_selection[p1_character].texture_normal = graybox
				p1_character+=1
				p1_selection[p1_character].texture_normal = purplebox
				on_character1_change()
				
		if is_action_just_pressed(1, "accept"):
			p1_locked = true
			$Background/Player1Text/P1Ready.show()
			NetworkManager.character_stage_screen_lock_in.rpc()
			on_locked_in()
	
	if !p2_locked:
		if is_action_just_pressed(2, "left") or is_action_just_pressed(2, "ui_left"):
			if p2_character <= 0:
				p2_selection[p2_character].texture_normal = graybox
				p2_selection[len(p2_selection)-1].texture_normal = bluebox
				p2_character = len(p2_selection)-1
				on_character2_change()
			else:
				p2_selection[p2_character].texture_normal = graybox
				p2_character-=1
				p2_selection[p2_character].texture_normal = bluebox
				on_character2_change()
		if is_action_just_pressed(2, "right") or is_action_just_pressed(2, "ui_right"):
			if p2_character >= len(p2_selection)-1:
				p2_selection[p2_character].texture_normal = graybox
				p2_selection[0].texture_normal = bluebox
				p2_character = 0
				on_character2_change()
			else:
				p2_selection[p2_character].texture_normal = graybox
				p2_character+=1
				p2_selection[p2_character].texture_normal = bluebox
				on_character2_change()

		if is_action_just_pressed(2, "accept") and !p2_locked:
			p2_locked = true
			$Background/Player2Text/P2Ready.show()
			NetworkManager.character_stage_screen_lock_in.rpc()
			
			on_locked_in()
		

func become_inactive():
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(get_viewport().size.x,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
	if NetworkManager.is_connected:
		NetworkManager.character_stage_screen_change_acked.disconnect(_on_character_screen_change_acked)
		NetworkManager.character_stage_screen_lock_in_acked.connect(_on_character_screen_lock_in_acked)
	
	set_process(false)
	get_parent().set_process(true)
	await get_tree().create_timer(.5).timeout
	queue_free()

func _on_character_screen_change_acked(player_num: int, character: int):
	if player_num == 0:
		p1_selection[p1_character].texture_normal = graybox
		p1_character = character
		p1_selection[p1_character].texture_normal = purplebox
		on_character1_change(false)
	else:
		p2_selection[p2_character].texture_normal = graybox
		p2_character = character
		p2_selection[p2_character].texture_normal = bluebox
		on_character2_change(false)

func _on_character_screen_lock_in_acked(player_num: int, character: int):
	if player_num == 0:
		p1_character = character
		$Background/Player1Text/P1Ready.show()
	else:
		p2_character = character
		$Background/Player2Text/P2Ready.show()
	
	_update_beginning_cutscene()

func on_character1_change(send_networked_response: bool = true):
	if send_networked_response and NetworkManager.is_connected:
		NetworkManager.character_stage_screen_character_change.rpc(p1_character)
	
	$P1Sounds.play()
	
	match (p1_character):
		0:
			p1_text.text = str("Cat")
			p1_portrait.texture = preload("res://gui/hud/sprites/cs_icons/cat_purple.png")
			p1_stat.texture = preload("res://gui/hud/sprites/character_stats/purple_cat_stats.png")
			
		1:
			p1_text.text = str("Fish")
			p1_portrait.texture = preload("res://gui/hud/sprites/cs_icons/fish_purple.png")
			p1_stat.texture = preload("res://gui/hud/sprites/character_stats/purple_fish_stats.png")
		2:
			p1_text.text = str("Turtle")
			p1_portrait.texture = preload("res://gui/hud/sprites/cs_icons/turtle_purple.png")
			p1_stat.texture = preload("res://gui/hud/sprites/character_stats/purple_turtle_stats.png")
	
	on_character2_change()
	_update_beginning_cutscene()

func on_character2_change(send_networked_response: bool = true):
	if send_networked_response and NetworkManager.is_connected:
		NetworkManager.character_stage_screen_character_change.rpc(p2_character)
	$P2Sounds.play()
	match (p2_character):
		0:
			p2_text.text = str("Cat")
			if p1_character == 0:
				p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/alternate_cat.png")
				p2_stat.texture = preload("res://gui/hud/sprites/character_stats/blue_cat_stats.png")
			else:
				p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/cat_blue.png")
				p2_stat.texture = preload("res://gui/hud/sprites/character_stats/blue_cat_stats.png")
		1:
			p2_text.text = str("Fish")
			if p1_character == 1:
				p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/alternate_fish.png")
				p2_stat.texture = preload("res://gui/hud/sprites/character_stats/blue_fish_stats.png")
			else:
				p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/fish_blue.png")
				p2_stat.texture = preload("res://gui/hud/sprites/character_stats/blue_fish_stats.png")
		2:
			p2_text.text = str("Turtle")
			if p1_character == 2:
				p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/alternate_turtle.png")
				p2_stat.texture = preload("res://gui/hud/sprites/character_stats/blue_turtle_stats.png")
			else:
				p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/turtle_blue.png")
				p2_stat.texture = preload("res://gui/hud/sprites/character_stats/blue_turtle_stats.png")
	_update_beginning_cutscene()

func _update_beginning_cutscene():
	# setting up the beginning cutscene
		var p1_character_string: String
		var p2_character_string: String
		
		match p1_character:
			0:
				p1_character_string = "cat"
			1:
				p1_character_string = "fish"
			2:
				p1_character_string = "turtle"
		
		match p2_character:
			0:
				p2_character_string = "cat"
			1:
				p2_character_string = "fish"
			2:
				p2_character_string = "turtle"
		
		var file_path: String = "res://gui/menus/cutscenes/pre_battle/%s_v_%s_pre_battle.ogv" \
			% [p1_character_string, p2_character_string]
		
		Globals.cutscene_player_video_path = file_path

func on_locked_in():
	#SET PLAYER CHARACTERS HERE
	
	Globals.player_sprites.clear()
	
	for player_text in [p1_text, p2_text]:
		Globals.player_sprites.append(player_text.text.to_lower())
		var player_path = "res://player/%s/%s.tscn" \
			% [player_text.text.to_lower(), player_text.text.to_lower()]
		ResourceLoader.load_threaded_request(player_path)
	
	$MenuSound.play()
	if p1_locked and p2_locked and \
	   (not NetworkManager.is_connected or NetworkManager._network_game_state == NetworkManager.NetworkGameState.STAGE_SELECT):
		var stage_select = preload("res://gui/menus/stage_select.tscn").instantiate()
		stage_select.position.x = get_viewport().size.x
		add_child(stage_select)
		
		if NetworkManager.is_connected:
			NetworkManager.character_stage_screen_change_acked.disconnect(_on_character_screen_change_acked)
			NetworkManager.character_stage_screen_lock_in_acked.connect(_on_character_screen_lock_in_acked)
		
		self.set_process(false)


func _on_button_mouse_entered(extra_arg_0):
	if NetworkManager.is_connected and NetworkManager.my_player_num == 1 and !p2_locked:
		p2_selection[p2_character].texture_normal = graybox
		p2_character = extra_arg_0
		p2_selection[p2_character].texture_normal = bluebox
		on_character2_change()
	elif !p1_locked:
		p1_selection[p1_character].texture_normal = graybox
		p1_character = extra_arg_0
		p1_selection[p1_character].texture_normal = purplebox
		on_character1_change()

func _p1_lock_in():
	if NetworkManager.is_connected and NetworkManager.my_player_num == 1 and !p2_locked:
		p2_locked = true
		$Background/Player2Text/P2Ready.show()
		NetworkManager.character_stage_screen_lock_in.rpc()
		on_locked_in()
	elif !p1_locked:
		p1_locked = true
		$Background/Player1Text/P1Ready.show()
		NetworkManager.character_stage_screen_lock_in.rpc()
		on_locked_in()


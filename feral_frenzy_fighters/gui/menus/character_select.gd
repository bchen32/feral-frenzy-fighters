extends Control

@onready var p1_portrait = $Background/PlayerPortraits/Player1Portrait
@onready var p2_portrait = $Background/PlayerPortraits/Player2Portrait
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

var cat_character: PackedScene = preload("res://player/cat/cat.tscn")
var fish_character: PackedScene = preload("res://player/fish/fish.tscn")

var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	
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
	ui = Globals.menu.new($Background)
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(true)   
	on_character1_change()
	on_character2_change()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
		else:
			become_inactive()
	if !p1_locked:
		if Input.is_action_just_pressed("p1_left"):
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
				
		if Input.is_action_just_pressed("p1_right"):
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
				
		if Input.is_action_just_pressed("p1_accept"):
			p1_locked = true
			$Background/Player1Text/P1Ready.show()
			on_locked_in()
	
	if !p2_locked:
		if Input.is_action_just_pressed("p2_left"):
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

		if Input.is_action_just_pressed("p2_right"):
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

		if Input.is_action_just_pressed("p2_accept"):
			p2_locked = true
			$Background/Player2Text/P2Ready.show()
			on_locked_in()
		

func become_inactive():
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(get_viewport().size.x,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(false)
	get_parent().set_process(true)
	await get_tree().create_timer(.5).timeout
	queue_free()
	
func on_character1_change():
	$P1Sounds.play()
	match (p1_character):
		0:
			p1_text.text = str("Cat")
			p1_portrait.texture = preload("res://gui/hud/sprites/cs_icons/cat_display.png")
		1:
			p1_text.text = str("Fish")
			p1_portrait.texture = preload("res://gui/hud/sprites/cs_icons/fish_display.png")
		2:
			p1_text.text = str("Turtle")
			
func on_character2_change():
	$P2Sounds.play()
	match (p2_character):
		0:
			p2_text.text = str("Cat")
			p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/cat_display.png")
		1:
			p2_text.text = str("Fish")
			p2_portrait.texture = preload("res://gui/hud/sprites/cs_icons/fish_display.png")
		2:
			p2_text.text = str("Turtle")

func on_locked_in():
	#SET PLAYER CHARACTERS HERE
	
	Globals.player_sprites.clear()
	
	for player_text in [p1_text, p2_text]:
		match player_text.text:
			"Cat":
				Globals.player_sprites.append(cat_character)
			"Fish":
				Globals.player_sprites.append(fish_character)
			"Turtle":
				pass
	
	$MenuSound.play()
	if p1_locked and p2_locked:
		var stage_select = preload("res://gui/menus/stage_select.tscn").instantiate()
		stage_select.position.x = get_viewport().size.x
		add_child(stage_select)
		self.set_process(false)


func _on_button_mouse_entered(extra_arg_0):
	if !p1_locked:
		p1_selection[p1_character].texture_normal = graybox
		p1_character = extra_arg_0
		p1_selection[p1_character].texture_normal = purplebox
		on_character1_change()
	
func _p1_lock_in():
	if !p1_locked:
		p1_locked = true
		$Background/Player1Text/P1Ready.show()
		on_locked_in()


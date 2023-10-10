extends Control

@onready var p1_portrait = $Background/PlayerPortraits/Player1Portrait
@onready var p2_portrait = $Background/PlayerPortraits/Player2Portrait
@onready var p1_text = $Background/Player1Text
@onready var p2_text = $Background/Player2Text

@onready var graybox = preload("res://gui/hud/sprites/head_icons/selection_box.png")
@onready var bluebox = preload("res://gui/hud/sprites/head_icons/playerone_select_character.png")
@onready var purplebox = preload("res://gui/hud/sprites/head_icons/playertwo_select_character.png")

var p1_selection = []
var p1_character = 0
var p2_selection = []
var p2_character = 0
var p1_locked = false
var p2_locked = false



var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for button in $Background/P1Buttons.get_children():
		if button.is_visible():
			p1_selection.append(button)
		
	for button in $Background/P2Buttons.get_children():
		if button.is_visible():
			p2_selection.append(button)
	
	p1_selection[0].texture_normal = bluebox
	p2_selection[0].texture_normal = purplebox
	$Background/Player1Text/P1Ready.hide()
	$Background/Player2Text/P2Ready.hide()
	
	show()
	ui = Globals.menu.new($Background)
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(true)   

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_back"):
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
			ui.back()
		else:
			become_inactive()
	if !p1_locked:
		if Input.is_action_just_pressed("p1_left"):
			if p1_character <= 0:
				p1_selection[p1_character].texture_normal = graybox
				p1_selection[len(p1_selection)-1].texture_normal = bluebox
				p1_character = len(p1_selection)-1
				on_character1_change()
			else:
				p1_selection[p1_character].texture_normal = graybox
				p1_character-=1
				p1_selection[p1_character].texture_normal = bluebox
				on_character1_change()
				
		if Input.is_action_just_pressed("p1_right"):
			if p1_character >= len(p1_selection)-1:
				p1_selection[p1_character].texture_normal = graybox
				p1_selection[0].texture_normal = bluebox
				p1_character = 0
				on_character1_change()
			else:
				p1_selection[p1_character].texture_normal = graybox
				p1_character+=1
				p1_selection[p1_character].texture_normal = bluebox
				on_character1_change()
	
	if !p2_locked:
		if Input.is_action_just_pressed("p2_left"):
			if p2_character <= 0:
				p2_selection[p2_character].texture_normal = graybox
				p2_selection[len(p2_selection)-1].texture_normal = purplebox
				p2_character = len(p2_selection)-1
				on_character2_change()
			else:
				p2_selection[p2_character].texture_normal = graybox
				p2_character-=1
				p2_selection[p2_character].texture_normal = purplebox
				on_character2_change()

		if Input.is_action_just_pressed("p2_right"):
			if p2_character >= len(p2_selection)-1:
				p2_selection[p2_character].texture_normal = graybox
				p2_selection[0].texture_normal = purplebox
				p2_character = 0
				on_character2_change()
			else:
				p2_selection[p2_character].texture_normal = graybox
				p2_character+=1
				p2_selection[p2_character].texture_normal = purplebox
				on_character2_change()
	
	if Input.is_action_just_pressed("p1_attack"):
		p1_locked = true
		$Background/Player1Text/P1Ready.show()
		on_locked_in()
	if Input.is_action_just_pressed("p2_attack"):
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
	#set player 1's character to p1_character
	#set player 2's character to p1_character
	#go next screen
	pass

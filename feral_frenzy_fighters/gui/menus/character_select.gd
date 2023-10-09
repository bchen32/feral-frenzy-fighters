extends Control

@onready var p1_portrait = $Background/PlayerPortraits/Player1Portrait
@onready var p2_portrait = $Background/PlayerPortraits/Player2Portrait
@onready var p1_text = $Background/PlayerNames/Player1Text
@onready var p2_text = $Background/PlayerNames/Player1Text

var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	ui = Globals.menu.new($Background)
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(true)
	$Background/HBoxContainer/Cat.grab_focus()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_back"):
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
			ui.back()
		else:
			become_inactive()

func become_inactive():
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(get_viewport().size.x,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(false)
	get_parent().set_process(true)
	await get_tree().create_timer(.5).timeout
	queue_free()


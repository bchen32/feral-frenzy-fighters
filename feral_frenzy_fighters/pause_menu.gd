extends Control

var ui

# Called when the node enters the scene tree for the first time.
func _ready():
	ui = Menu.new($OptionsDialog)
	$OptionsDialog/DialogBackground/OptionsUIArea/VBoxContainer/VolumeButton.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_back"):
		_on_volume_button_pressed()
	
func _on_volume_button_pressed():
	if len(ui._queue) <= 1:
		get_tree().paused = false
		_button_hovered()
		queue_free()
	else:
		ui.back()


func _on_moveset_button_pressed():
	ui.next($ScuffSolution/MovesetDialog)

	
func _button_hovered():
	var back_sound = preload("res://player/randomSFX.tscn").instantiate()
	back_sound.stream = preload("res://gui/menus/sfx/button.wav")
	get_parent().add_child(back_sound)
	back_sound.volume_db = -5
	back_sound.play()


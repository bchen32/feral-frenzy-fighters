extends Control

var ui
var active = false
var connect = load("res://common/network_manager.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready():
	active = false
	ui = Menu.new($OptionsDialog)
	$OptionsDialog/DialogBackground/OptionsUIArea/VBoxContainer/ResumeButton.grab_focus()
	await get_tree().create_timer(0.1).timeout
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_moveset_button_pressed():
	ui.next($ScuffSolution/MovesetDialog)

	
func _button_hovered():
	var back_sound = preload("res://player/randomSFX.tscn").instantiate()
	back_sound.stream = preload("res://gui/menus/sfx/button.wav")
	get_parent().add_child(back_sound)
	back_sound.volume_db = -5
	back_sound.play()

func _on_quit_button_pressed():
	#connect._disconnect() (no idea)
	get_tree().change_scene_to_file("res://gui/menus/title_screen.tscn")

func _on_resume_button_pressed():
	$".".hide()


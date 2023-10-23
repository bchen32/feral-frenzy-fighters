extends Control

@export var beginning_cutscene_path: String

@onready var music_slider = $MainMenu/AudioSliders/VBoxContainer/MusicSlider
@onready var sfx_slider = $MainMenu/AudioSliders/VBoxContainer/SfxSlider

var ui

func _ready():
	if NetworkManager.SERVER_BUILD:
		$HostButton.show()
	music_slider.value = 25 if Globals.music_val == -1 else Globals.music_val
	sfx_slider.value = 125 if Globals.sfx_val == -1 else Globals.sfx_val
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_slider.value / 100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_slider.value / 100))
	$"MainMenu/Title/ButtonsVBox/Play/PlayButton".grab_focus()
	Globals.setup_controls()
	
	ui = Globals.menu.new($MainMenu/Title)

func _process(delta):
	if InputManager.is_action_pressed("ui_back"):
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
			ui.back()

func _on_play_button_pressed():
	ui.next($MainMenu/PlayDialog)
	_on_button_selected()

func _on_credits_button_pressed():
	$MainMenu/TopBarButtons/InstructionsButton.character = ""
	$MainMenu/TopBarButtons/InstructionsButton.refresh_button_apperance()
	$MainMenu/TopBarButtons/InstructionsButton.grab_focus()
	_on_button_selected()
	ui.next($MainMenu/Credits)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_credits_back_button_pressed():
	ui.back()

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

func _on_instructions_button_pressed():
	ui.next($MainMenu/Instructions)
	_on_button_selected()

func _on_settings_button_button_pressed():
	pass # Replace with function body.

func _on_play_dialog_on_online_button_pressed():
	Globals.cutscene_player_video_path = beginning_cutscene_path
	Globals.cutscene_player_end_game = false
	Globals.audio_stream_to_play_during_cutscene = preload("res://levels/cat_tree/music/catfight.wav")
	
	NetworkManager.establish_connection()

func _on_play_dialog_on_local_button_pressed():
	Globals.cutscene_player_video_path = beginning_cutscene_path
	Globals.cutscene_player_end_game = false
	Globals.audio_stream_to_play_during_cutscene = preload("res://levels/cat_tree/music/catfight.wav")
	var character_select = preload("res://gui/menus/character_select.tscn").instantiate()
	character_select.position.x = get_viewport().size.x
	add_child(character_select)
	_on_button_selected()
	set_process(false)
	$MainMenu.hide() #This unfocuses the menu buttons. Please don't ask.
	$MainMenu.show()


func _on_play_button_mouse_entered():
	for children in $MainMenu/BloodySplatters.get_children():
		children.show()

func _on_play_button_mouse_exited():
	for children in $MainMenu/BloodySplatters.get_children():
		children.hide()

func _on_options_button_pressed():
	ui.next($"MainMenu/AudioSliders")
	_on_button_selected()
func _on_host_button_pressed():
	NetworkManager.become_host()

func _on_music_slider_value_changed(value):
	Globals.music_val = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100))

func _on_sfx_slider_value_changed(value):
	Globals.sfx_val = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100))

func _on_button_entered():
	$SFX.stream = preload("res://gui/menus/sfx/button.wav")
	$SFX.play()

func _on_button_selected():
	$SFX.stream = preload("res://gui/menus/sfx/select.wav")
	$SFX.play()

func _on_tutorial_button_pressed():
	get_tree().change_scene_to_file("res://levels/tutorial/tutorial.tscn")
	



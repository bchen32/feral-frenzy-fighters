extends Control

@export var beginning_cutscene_path: String
var character_select
var stage_select
var ui

func _ready():
	$"MainMenu/AudioSliders/VBoxContainer/MusicSlider".value = 50 if Globals.music_val == -1 else Globals.music_val
	$"MainMenu/AudioSliders/VBoxContainer/SfxSlider".value = 100 if Globals.sfx_val == -1 else Globals.sfx_val
	$"MainMenu/Title/ButtonsVBox/Play/PlayButton".grab_focus()
	
	ui = Globals.menu.new($MainMenu/Title)
	character_select = $CharacterSelect

func _process(delta):
	if Input.is_action_pressed("ui_back"):
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
	pass
	#Globals.cutscene_player_video_path = beginning_cutscene_path
	#Globals.cutscene_player_end_game = false
	#Globals.audio_stream_to_play_during_cutscene = preload("res://levels/cat_tree/music/catfight.wav")
	
	#NetworkManager.establish_connection()

func _on_play_dialog_on_local_button_pressed():
	Globals.cutscene_player_video_path = beginning_cutscene_path
	Globals.cutscene_player_end_game = false
	Globals.audio_stream_to_play_during_cutscene = preload("res://levels/cat_tree/music/catfight.wav")
	
	_on_button_selected()
	character_select.become_active()
	self.set_process(false)
	
	

func _on_play_button_mouse_entered():
	for children in $MainMenu/BloodySplatters.get_children():
		children.show()

func _on_play_button_mouse_exited():
	for children in $MainMenu/BloodySplatters.get_children():
		children.hide()

func _on_options_button_pressed():
	ui.next($"MainMenu/AudioSliders")
	_on_button_selected()

func _on_music_slider_value_changed(value):
	var music_max = $"MainMenu/AudioSliders/VBoxContainer/MusicSlider".max_value
	Globals.music_val = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / music_max))

func _on_sfx_slider_value_changed(value):
	var sfx_max = $"MainMenu/AudioSliders/VBoxContainer/SfxSlider".max_value
	Globals.sfx_val = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / sfx_max))

func _on_button_entered():
	$SFX.stream = preload("res://gui/menus/sfx/button.wav")
	$SFX.play()

func _on_button_selected():
	$SFX.stream = preload("res://gui/menus/sfx/select.wav")
	$SFX.play()


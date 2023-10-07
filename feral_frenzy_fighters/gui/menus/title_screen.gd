extends Control

@export var beginning_cutscene_path: String

var ui

class menu:
	var _queue = []
	
	func _init(item):
		_queue.append(item)
		self._queue = _queue
		print("starting with", item)
	
	func next(item):
		_queue.back().hide()
		_queue.append(item)
		item.show()
		print("appending", item)
		
	func back():
		print("popping", _queue.back())
		_queue.pop_back().hide()
		_queue.back().show()
		
		


func _ready():
	$"Background/AudioSliders/VBoxContainer/MusicSlider".value = 50 if Globals.music_val == -1 else Globals.music_val
	$"Background/AudioSliders/VBoxContainer/SfxSlider".value = 100 if Globals.sfx_val == -1 else Globals.sfx_val
	$Background/Title/ButtonsVBox/Play/PlayButton.grab_focus()
	ui = menu.new($Background/Title)
	
	
func _on_play_button_pressed():
	ui.next($Background/PlayDialog)

func _on_credits_button_pressed():
	$Background/TopBarButtons/InstructionsButton.character = ""
	$Background/TopBarButtons/InstructionsButton.refresh_button_apperance()
	$Background/TopBarButtons/InstructionsButton.grab_focus()
	
	ui.next($Background/Credits)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_credits_back_button_pressed():
	ui.back()
	
func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

func _on_instructions_button_pressed():
	if $Background/TopBarButtons/InstructionsButton.character != "":
		$Background/TopBarButtons/InstructionsButton.character = ""
		ui.next($Background/Instructions)
	else:
		# coming from instructions/credits screen
		$Background/TopBarButtons/InstructionsButton.character = "?"
		ui.back()
	
	$Background/TopBarButtons/InstructionsButton.refresh_button_apperance()

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
	get_tree().change_scene_to_file("res://gui/menus/cutscene_player.tscn")
	
	
func _on_play_button_mouse_entered():
	$Background/BloodyKnife.show()
	$Background/BloodyCorner.show()
	$Background/BloodSplatOne.show()
	$Background/BloodSplatTwo.show()
	$Background/BloodyKnife.show() 


func _on_play_button_mouse_exited():
	$Background/BloodyKnife.hide()
	$Background/BloodyCorner.hide()
	$Background/BloodSplatOne.hide()
	$Background/BloodSplatTwo.hide()


func _on_options_button_pressed():
	if $Background/TopBarButtons/InstructionsButton.character != "":
		$Background/TopBarButtons/InstructionsButton.character = ""
		ui.next($"Background/AudioSliders")
	else:
		$Background/TopBarButtons/InstructionsButton.character = "?"
		ui.back()
	$Background/TopBarButtons/InstructionsButton.refresh_button_apperance()


func _on_music_slider_value_changed(value):
	var music_max = $"Background/AudioSliders/VBoxContainer/MusicSlider".max_value
	Globals.music_val = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / music_max))
	


func _on_sfx_slider_value_changed(value):
	var sfx_max = $"Background/AudioSliders/VBoxContainer/SfxSlider".max_value
	Globals.sfx_val = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / sfx_max))

extends Control

@export var beginning_cutscene_path: String


func _on_play_button_pressed():
	$Background/PlayDialog.show()

func _on_credits_button_pressed():
	$Background/TopBarButtons/InstructionsButton.character = ""
	$Background/TopBarButtons/InstructionsButton.refresh_button_apperance()
	
	$Background/Credits.show()
	$Background/Title.hide()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_credits_back_button_pressed():
	$Background/Credits.hide()
	$Background/Title.show()

func _on_audio_stream_player_2d_finished():
	$AudioStreamPlayer2D.play()

func _on_instructions_button_pressed():
	if $Background/TopBarButtons/InstructionsButton.character != "":
		# going to instructions screen
		$Background/TopBarButtons/InstructionsButton.character = ""
		$Background/Title.hide()
		$Background/Instructions.show()
	else:
		# coming from instructions/credits screen
		$Background/TopBarButtons/InstructionsButton.character = "?"
		$Background/Title.show()
		$Background/Instructions.hide()
		$Background/Credits.hide()
	
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




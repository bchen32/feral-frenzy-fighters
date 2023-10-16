extends Node

enum States { AIR, AIR_ATTACK, AIR_JUMP, DASH, DASH_ATTACK, DASH_JUMP, GROUND_ATTACK, HIT, IDLE, WALK, WALK_JUMP }

var cutscene_player_video_path: String = "res://gui/menus/cutscenes/intro_cutscene.ogv"
var cutscene_player_end_game: bool = false
var player1_won: bool = false

var audio_stream_to_play_during_cutscene: AudioStream



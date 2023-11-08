extends Control

@onready var character_animation = $DialogBackground/MovesetUIArea/PlayerSprite/characteranim

@onready var character_text = $DialogBackground/MovesetUIArea/Character
@onready var move_text = $DialogBackground/MovesetUIArea/Moves

var characters = ["cat", "fish", "turtle"]
var moves = ["nattack", "nair", "dattack"]
var display_moves = ["Grounded Attack", "Air Attack", "Dash Attack"]

var controls = {}

var current_move = 0
var current_character = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_display()


func _on_next_move_pressed():
	if current_move >= len(moves)-1:
		current_move = 0
	else:
		current_move +=1
		
	_update_display()


func _on_last_move_pressed():
	if current_character <= 0:
		current_character = len(characters)-1
	else:
		current_character -=1
		
	_update_display()

func _on_next_character_pressed():
	if current_character >= len(characters)-1:
		current_character = 0
	else:
		current_character +=1
		
	_update_display()


func _on_last_character_pressed():
	if current_move <= 0:
		current_move = len(moves)-1
	else:
		current_move -=1
		
	_update_display()
	
	
func _update_display():
	move_text.text = display_moves[current_move].to_upper()
	character_text.text = characters[current_character]
	
	character_animation.animation = "%s_%s" % [characters[current_character],moves[current_move]]
	
	character_animation.play()

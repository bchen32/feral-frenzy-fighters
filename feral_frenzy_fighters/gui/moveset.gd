extends Control

@onready var character_animation = $DialogBackground/MovesetUIArea/PlayerSprite/characteranim

@onready var character_text = $DialogBackground/MovesetUIArea/Character
@onready var move_text = $DialogBackground/MovesetUIArea/Moves

var characters = ["cat", "fish", "turtle"]
var moves = ["nattack", "nair", "dattack"]
var display_moves = ["Grounded Attack", "Air Attack", "Dash Attack"]

var controls = {
	0 : ["attack","none","none"],
	1 : ["jump","attack","none"],
	2 : ["dash","attack","none"]
}

@onready var control_anims = [
	$DialogBackground/MovesetUIArea/VBoxContainer/Control/C1,
	$DialogBackground/MovesetUIArea/VBoxContainer/Control2/C2,
	$DialogBackground/MovesetUIArea/VBoxContainer/Control3/C3
]

var current_move = 0
var current_character = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_display()
	_update_controls()

func _on_next_move_pressed():
	if current_move >= len(moves)-1:
		current_move = 0
	else:
		current_move +=1
		
	_update_display()
	_update_controls()


func _on_last_move_pressed():
	if current_move <= 0:
		current_move = len(moves)-1
	else:
		current_move -=1
		
	_update_display()
	_update_controls()

func _on_next_character_pressed():
	if current_character >= len(characters)-1:
		current_character = 0
	else:
		current_character +=1
		
	_update_display()


func _on_last_character_pressed():
	if current_character <= 0:
		current_character = len(characters)-1
	else:
		current_character -=1
		
	_update_display()
	
	
func _update_display():
	move_text.text = display_moves[current_move]
	character_text.text = characters[current_character]
	
	character_animation.animation = "%s_%s" % [characters[current_character],moves[current_move]]
	
	character_animation.play()
	
func _update_controls():
	for x in range(0, len(control_anims)):
		control_anims[x].animation = controls[current_move][x]
		control_anims[x].stop()
		control_anims[x].play()


func _on_back_button_pressed():
	get_parent().get_parent().ui.back()
	pass # Replace with function body.

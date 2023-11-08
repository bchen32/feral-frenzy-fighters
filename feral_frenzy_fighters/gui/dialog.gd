extends Control

signal on_first_button_pressed
signal on_second_button_pressed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_close_button_button_pressed():
	self.owner.ui.back()

func _on_first_button_pressed():
	on_first_button_pressed.emit()

func _on_second_button_pressed():
	on_second_button_pressed.emit()


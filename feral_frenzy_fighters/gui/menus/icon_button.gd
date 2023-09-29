extends Control

@export var character: String = ""
@export var icon_texture: Texture2D = null
@export var is_blue_button: bool = false

signal button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_button_apperance()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func refresh_button_apperance():
	if character != "":
		$IconButtonClick/Label.text = character
		
		$IconButtonClick/Icon.hide()
		$IconButtonClick/Label.show()
	elif icon_texture != null:
		$IconButtonClick/Icon.texture = icon_texture
		
		$IconButtonClick/Icon.show()
		$IconButtonClick/Label.hide()
	
	if is_blue_button:
		$IconButtonClick.texture_normal = preload("res://gui/menus/sprites/buttons/button_icon_blue.png")
		$IconButtonClick.texture_hover = preload("res://gui/menus/sprites/buttons/button_icon_blue_highlight.png")
		$IconButtonClick.texture_pressed = preload("res://gui/menus/sprites/buttons/button_icon_blue_pressed.png")
	else:
		$IconButtonClick.texture_normal = preload("res://gui/menus/sprites/buttons/button_icon.png")
		$IconButtonClick.texture_hover = preload("res://gui/menus/sprites/buttons/button_icon_highlight.png")
		$IconButtonClick.texture_pressed = preload("res://gui/menus/sprites/buttons/button_icon_pressed.png")
	

func _on_icon_button_click_pressed():
	button_pressed.emit()

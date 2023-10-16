extends Control

signal chat_sent

@export var _is_blue_popup: bool = false

var _is_mouse_hovering: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_is_blue_popup(_is_blue_popup)

func set_is_blue_popup(is_blue_popup: bool):
	_is_blue_popup = is_blue_popup
	
	var background_texture: Texture = \
			preload("res://gui/menus/sprites/screens/reactions_pop_up_blue.png") if(is_blue_popup) else \
		preload("res://gui/menus/sprites/screens/reactions_pop_up.png") 
	var chat_texture: Texture = \
		preload("res://gui/menus/sprites/buttons/icons/chat_icon_blue.png") if(is_blue_popup) else \
		preload("res://gui/menus/sprites/buttons/icons/chat_icon.png") 
	var skull_texture: Texture = \
		preload("res://gui/menus/sprites/buttons/icons/reaction_skull_icon_blue.png") if(is_blue_popup) else \
		preload("res://gui/menus/sprites/buttons/icons/reaction_skull_icon.png") 
	var thumbs_down_texture: Texture = \
		preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_down_icon_blue.png") if(is_blue_popup) else \
		preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_down_icon.png") 
	var thumbs_up_texture: Texture = \
		preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_up_icon_blue.png") if(is_blue_popup) else \
		preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_up_icon.png") 
	
	$ChatPopupBackground/VBoxContainer/ThumbsDownButton.icon_texture = thumbs_down_texture
	$ChatPopupBackground/VBoxContainer/ThumbsDownButton.is_blue_button = _is_blue_popup
	$ChatPopupBackground/VBoxContainer/ThumbsDownButton.refresh_button_apperance()
	
	$ChatPopupBackground/VBoxContainer/ThumbsUpButton.icon_texture = thumbs_up_texture
	$ChatPopupBackground/VBoxContainer/ThumbsUpButton.is_blue_button = _is_blue_popup
	$ChatPopupBackground/VBoxContainer/ThumbsUpButton.refresh_button_apperance()
	
	$ChatPopupBackground/VBoxContainer/SkullButton.icon_texture = skull_texture
	$ChatPopupBackground/VBoxContainer/SkullButton.is_blue_button = _is_blue_popup
	$ChatPopupBackground/VBoxContainer/SkullButton.refresh_button_apperance()
	
	$ChatPopupShowButton.icon_texture = chat_texture
	$ChatPopupShowButton.is_blue_button = _is_blue_popup
	$ChatPopupShowButton.refresh_button_apperance()
	
	$ChatPopupBackground.texture = background_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $ChatPopupBackground.is_visible_in_tree():
		if _is_mouse_hovering:
			$Timer.stop()
		elif $Timer.is_stopped():
			$Timer.start(2)
	
	if not _is_blue_popup:
		if InputManager.is_action_pressed("p1_thumbs_up"):
			_send_chat_message(NetworkManager.ChatEmoji.THUMBS_UP)
		elif InputManager.is_action_pressed("p1_thumbs_down"):
			_send_chat_message(NetworkManager.ChatEmoji.THUMBS_DOWN)
		elif InputManager.is_action_pressed("p1_skull"):
			_send_chat_message(NetworkManager.ChatEmoji.SKULL)
	elif not NetworkManager.is_connected:
		if InputManager.is_action_pressed("p2_thumbs_up"):
			_send_chat_message(NetworkManager.ChatEmoji.THUMBS_UP)
		elif InputManager.is_action_pressed("p2_thumbs_down"):
			_send_chat_message(NetworkManager.ChatEmoji.THUMBS_DOWN)
		elif InputManager.is_action_pressed("p2_skull"):
			_send_chat_message(NetworkManager.ChatEmoji.SKULL)

func _on_timer_timeout():
	$ChatPopupShowButton.show()
	$ChatPopupBackground.hide()

func _on_chat_popup_show_button_button_pressed():
	$ChatPopupShowButton.hide()
	$ChatPopupBackground.show()

func _on_mouse_entered():
	_is_mouse_hovering = true

func _on_mouse_exited():
	_is_mouse_hovering = false

func _send_chat_message(chat_emoji: NetworkManager.ChatEmoji):
	if NetworkManager.is_connected:
		NetworkManager.report_chat.rpc(chat_emoji)
	else:
		chat_sent.emit(chat_emoji)


func _on_thumbs_down_button_button_pressed():
	_send_chat_message(NetworkManager.ChatEmoji.THUMBS_DOWN)

func _on_thumbs_up_button_button_pressed():
	_send_chat_message(NetworkManager.ChatEmoji.THUMBS_UP)

func _on_skull_button_button_pressed():
	_send_chat_message(NetworkManager.ChatEmoji.SKULL)

extends Control

func _ready():
	if NetworkManager.is_connected:
		NetworkManager.connect("chat_acked", acknowledge_chat)
		
		if NetworkManager.my_player_num == 0:
			$P2/ChatPopup.hide()
		else:
			#assert(NetworkManager.my_player_num == 1)
			
			$P1/ChatPopup.hide()
	else:
		$P1/ChatPopup.hide()
		$P2/ChatPopup.hide()

func set_player_damage(player_num: int, player_knockback_percentage: int):
	var text_string: String = str(player_knockback_percentage)
	text_string += "%"
	match player_num:
		0:
			$P1/DamageLabel.text = text_string
		1:
			$P2/DamageLabel.text = text_string

func set_player_death_count(player_num: int, death_count: int):
	match player_num:
		0:
			$P1/KOLabel.text = str(death_count)
		1:
			$P2/KOLabel.text = str(death_count)


func acknowledge_chat(player_num: int, chat_emoji: NetworkManager.ChatEmoji):
	if player_num == 0:
		match chat_emoji:
			NetworkManager.ChatEmoji.THUMBS_UP:
				$P1/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_up_icon.png")
			NetworkManager.ChatEmoji.THUMBS_DOWN:
				$P1/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_down_icon.png")
			NetworkManager.ChatEmoji.SKULL:
				$P1/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_skull_icon.png")
		
		$P1/ChatParticles.emitting = true
	else:
		assert(player_num == 1)
		
		match chat_emoji:
			NetworkManager.ChatEmoji.THUMBS_UP:
				$P2/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_up_icon_blue.png")
			NetworkManager.ChatEmoji.THUMBS_DOWN:
				$P2/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_down_icon_blue.png")
			NetworkManager.ChatEmoji.SKULL:
				$P2/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_skull_icon_blue.png")
		
		$P2/ChatParticles.emitting = true

func _on_p1_chat_sent(chat_emoji: NetworkManager.ChatEmoji):
	acknowledge_chat(0, chat_emoji)

func _on_p2_chat_sent(chat_emoji: NetworkManager.ChatEmoji):
	acknowledge_chat(1, chat_emoji)

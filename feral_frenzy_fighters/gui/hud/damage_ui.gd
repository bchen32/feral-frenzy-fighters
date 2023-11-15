extends Control

class_name DamageUI

@export var tutorial_mode: bool = false

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
	
	if tutorial_mode:
		$P1/KOLabel.text = "∞"

func set_player_damage(player_num: int, player_knockback_percentage: int):
	var text_string: String = str(player_knockback_percentage)
	text_string += "%"
	match player_num:
		0:
			$P1/DamageLabel.text = text_string
		1:
			$P2/DamageLabel.text = text_string
		2:
			$P2/DamageLabel.text = text_string


func set_player_death_count(player_num: int, death_count: int):
	match player_num:
		0:
			if not tutorial_mode:
				$P1/KOLabel.text = str(death_count)
				$P1/LivesLeft.set_num_lives(death_count)
		1, 2:
			$P2/KOLabel.text = str(death_count)
			$P2/LivesLeft.set_num_lives(death_count)

	if ($P2/KOLabel.text == "5"):
		$P2/BloodSplatTwo.hide()
		$P2/BloodSplatOne.hide()
		$P2/BloodyCorner.hide()
	if ($P2/KOLabel.text == "3"):
		$P2/BloodSplatTwo.show()
	if ($P2/KOLabel.text == "2"):
		$P2/BloodSplatOne.show()
	if ($P2/KOLabel.text == "1"):
		$P2/BloodyCorner.show()

	if ($P1/KOLabel.text == "5"):
		$P1/BloodSplatTwo2.hide()
		$P1/BloodSplatOne2.hide()
		$P1/BloodyCorner2.hide()
	if ($P1/KOLabel.text == "3"):
		$P1/BloodSplatTwo2.show()
	if ($P1/KOLabel.text == "2"):
		$P1/BloodSplatOne2.show()
	if ($P1/KOLabel.text == "1"):
		$P1/BloodyCorner2.show()



func acknowledge_chat(player_num: int, chat_emoji: NetworkManager.ChatEmoji):
	if player_num == 0:
		match chat_emoji:
			NetworkManager.ChatEmoji.THUMBS_UP:
				$P1/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_up_icon.png")
				$SFX.stream = preload("res://gui/menus/sfx/good.wav")
				$SFX.play()
			NetworkManager.ChatEmoji.THUMBS_DOWN:
				$P1/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_down_icon.png")
				$SFX.stream = preload("res://gui/menus/sfx/bad.wav")
				$SFX.play()
			NetworkManager.ChatEmoji.SKULL:
				$P1/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_skull_icon.png")
				$SFX.stream = preload("res://gui/menus/sfx/pretend_its_bones.wav")
				$SFX.play()
		
		$P1/ChatParticles.emitting = true
	else:
		assert(player_num == 1)
		
		match chat_emoji:
			NetworkManager.ChatEmoji.THUMBS_UP:
				$P2/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_up_icon_blue.png")
				$SFX.stream = preload("res://gui/menus/sfx/good.wav")
				$SFX.play()
			NetworkManager.ChatEmoji.THUMBS_DOWN:
				$P2/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_thumb_down_icon_blue.png")
				$SFX.stream = preload("res://gui/menus/sfx/bad.wav")
				$SFX.play()
			NetworkManager.ChatEmoji.SKULL:
				$P2/ChatParticles.texture = preload("res://gui/menus/sprites/buttons/icons/reaction_skull_icon_blue.png")
				$SFX.stream = preload("res://gui/menus/sfx/pretend_its_bones.wav")
				$SFX.play()
		
		$P2/ChatParticles.emitting = true

func _on_p1_chat_sent(chat_emoji: NetworkManager.ChatEmoji):
	acknowledge_chat(0, chat_emoji)

func _on_p2_chat_sent(chat_emoji: NetworkManager.ChatEmoji):
	acknowledge_chat(1, chat_emoji)

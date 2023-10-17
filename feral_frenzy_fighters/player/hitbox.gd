class_name Hitbox
extends Area2D

@onready var collision_shape = $CollisionShape2D

var excludes: Array[Node2D] = []
var dmg: float
var kb_scale: float
var kb_x_offset: float
var kb_y_offset: float


func setup(width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset):
	collision_shape.shape.extents = Vector2(width, height)
	translate(Vector2(x_offset, y_offset))
	dmg = damage
	kb_scale = knockback_scale
	kb_x_offset = knockback_x_offset
	kb_y_offset = knockback_y_offset
	excludes.append(get_parent())
	excludes.append(self)
	self.body_entered.connect(_on_body_entered)
	self.area_entered.connect(_on_area_2d_area_entered)


func _on_body_entered(body: Node2D):
	if body not in excludes and body is PlayerCharacter:
		excludes.append(body)  # only process collision once
		
		if not NetworkManager.is_connected:
			body.percentage += dmg
			body.play_audio(PlayerCharacter.AudioType.HIT)
			var kb = get_kb(body)
			var body_pos = body.global_position
			body_pos.x += kb_x_offset
			body_pos.y += kb_y_offset
			var angle = get_parent().global_position.angle_to_point(body_pos)
			body.hit = true
			body.kb = kb
			body.kb_angle = angle
			
			if NetworkManager.is_host:
				NetworkManager.update_damage_label.rpc(body.player_num, body.percentage, body.stocks)

func _on_area_2d_area_entered(area):
	if self.get_parent() is PlayerCharacter:
		if area.get_parent() is Interactable:
			area.get_parent()._change_health(-dmg)

func get_kb(body: PlayerCharacter):
	# Modified SSB formula
	return (
		(
			(
				((body.percentage / 10.0) + (body.percentage * dmg / 20.0))
				* body.inverse_weight
				* 1.4
			)
			+ body.kb_base
		)
		* kb_scale
	)

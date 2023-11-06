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
		
		if NetworkManager.is_connected:
			var hit_info: Dictionary = {
				"dmg": dmg,
				"kb": get_kb(body),
				"kb_y_offset": kb_y_offset,
				"kb_angle": get_parent().global_position.angle_to_point(body.global_position + Vector2(0, kb_y_offset))
			}
			
			NetworkManager.report_hit.rpc(body.player_num, hit_info)
		else:
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

func _on_area_2d_area_entered(area):
	if self.get_parent() is PlayerCharacter:
		if area.get_parent() is Interactable:
			if NetworkManager.is_connected:
				NetworkManager.report_env_hit.rpc(area.get_parent().name, -dmg)
			else:
				area.get_parent()._change_health(-dmg)

func get_kb(body: PlayerCharacter):
	# Modified SSB formula
	return (
		(
			(
				((body.percentage / 10.0) + (body.percentage * dmg / 20.0))
				* body.stats.inverse_weight
				* 1.4
			)
			+ body.stats.kb_base
		)
		* kb_scale
	)

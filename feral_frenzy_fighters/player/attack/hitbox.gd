class_name Hitbox
extends Area2D

@onready var collision_shape = $CollisionShape2D

var excludes: Array[Node2D] = []
var dmg: float
var kb_scale: float
var kb_x_offset: float
var kb_y_offset: float
var projectile: bool


func setup(width, height, x_offset, y_offset, damage, knockback_scale, knockback_x_offset, knockback_y_offset, is_projectile, exclude):
	collision_shape.shape.extents = Vector2(width, height)
	translate(Vector2(x_offset, y_offset))
	dmg = damage
	kb_scale = knockback_scale
	kb_x_offset = knockback_x_offset
	kb_y_offset = knockback_y_offset
	excludes.append(self)
	self.body_entered.connect(_on_body_entered)
	self.area_entered.connect(_on_area_2d_area_entered)
	projectile = is_projectile
	excludes.append(exclude)


func _on_body_entered(body: Node2D):
	var exclude = false
	if body not in excludes and body is PlayerCharacter:
		exclude = true
		if projectile:
			get_parent().collide()
		if NetworkManager.is_connected and body.character_type != "beanbag":
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
		excludes.append(body)  # only process collision once


func _on_area_2d_area_entered(area):
	if area.get_parent() is Interactable:
		if self.get_parent() is PlayerCharacter or projectile:
			if NetworkManager.is_connected:
				NetworkManager.report_env_hit.rpc(area.get_parent().name, -dmg)
			else:
				area.get_parent()._change_health(-dmg)
			if projectile:
				get_parent().collide()
		

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

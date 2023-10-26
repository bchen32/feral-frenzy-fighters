extends Node2D

@export var p1_tiki: bool = true
@onready var tiki_sprites = [
	load("res://levels/fish_tank/sprites/decor/tiki_cat_head.png"),
	load("res://levels/fish_tank/sprites/decor/tiki_fish_head.png"),
	load("res://levels/fish_tank/sprites/decor/tiki_turtle_head.png")
]
@onready var sprite = get_node("Sprite2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	if !Globals.player_sprites.is_empty():
		var p1_chr = Globals.player_sprites[0]
		var p2_chr = Globals.player_sprites[1]
		
		if p1_tiki == true:
			match (p1_chr):
				"res://player/cat/cat.tscn":
					sprite.texture = tiki_sprites[0]
				"res://player/fish/fish.tscn":
					sprite.texture = tiki_sprites[1]
		if p1_tiki == false:
			match (p2_chr):
				"res://player/cat/cat.tscn":
					sprite.texture = tiki_sprites[0]
				"res://player/fish/fish.tscn":
					sprite.texture = tiki_sprites[1]

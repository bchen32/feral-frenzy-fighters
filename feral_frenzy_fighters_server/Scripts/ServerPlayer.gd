extends CharacterBody2D

class_name ServerPlayer

enum StateType {
	AIR,
	AIRJUMP,
	ATTACK,
	DASH,
	DASHJUMP,
	HIT,
	IDLE,
	WALK,
	WALKJUMP
}

# network identification variables
var display_name: String
var player_num: int # Player 1(0), Player 2(1), etc.
var player_id: int # the unique id the server gives to the player
var stock: int = 0
var percentage: int = 0

# game state variables
var player_position: Vector2
var player_state_type: StateType = StateType.AIR
var flip_h: bool = false

func _init(player_num: int, player_id: int):
	self.display_name = "Player %s" % player_num
	self.player_num = player_num
	self.player_id = player_id

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends TextureRect

var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	%TipText.text = "[center]" + select_tip() + "[/center]"

func _process(delta):
	rotate_wheel(delta, .1)

func rotate_wheel(delta, og_timer):
	if timer <= 0:
		%Wheel.rotation_degrees += 45
		timer = og_timer
	else:
		timer -= delta
		
func select_tip():
	var tips = []
	var file = FileAccess.open("res://gui/menus/sprites/screens/Tips.txt", FileAccess.READ)
	var content = file.get_as_text()

	for line in content.split("\n"):
		tips.append(line)
	
	tips.shuffle()
	
	while tips[0] == "":
		tips.shuffle()

	return tips[0]

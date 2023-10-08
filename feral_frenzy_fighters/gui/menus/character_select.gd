extends Control
var ui
# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = get_viewport().size.x
	ui = Globals.menu.new($Background)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_back"):
		if len(ui._queue) > 1:
			$SFX.stream = preload("res://gui/menus/sfx/unbutton.wav")
			$SFX.play()
			ui.back()
		else:
			become_inactive()

func become_active():
	show()
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(0,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(true)

func become_inactive():
	var tween := create_tween()
	tween.tween_property($Background, "global_position", Vector2(get_viewport().size.x,0), .5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	set_process(false)
	get_parent().set_process(true)


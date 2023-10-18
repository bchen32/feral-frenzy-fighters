class_name BeanbagAirState
extends State

var play_anim: bool


func enter():
	play_anim = true


func update(delta):
	if character.is_on_floor():
		return Globals.States.IDLE
	else:
		if character.velocity.y > 0 and play_anim:	
			character.play_anim("fall")
			play_anim = false
		character.velocity.y += character.get_grav() * delta
		character.velocity.y = minf(character.velocity.y, character.stats.terminal_vel)
		return Globals.States.AIR

extends Node

class_name StateMachine

var character: PlayerCharacter
var states: Dictionary
var curr_state: Globals.States


func init(p_character, p_states, p_curr_state):
	character = p_character
	states = p_states
	curr_state = p_curr_state
	for state in states:
		states[state].character = character
	states[curr_state].enter()

func update(delta):
	if character.hit:
		transition(Globals.States.HIT)
	var next_state = states[curr_state].update(delta)
	# If transition, update new state instead
	# note: this implies that if a state is going to transition
	# it should return before it performs any updates
	# so that only one state is actually run per frame
	
	while next_state != curr_state:
		transition(next_state)
		next_state = states[curr_state].update(delta)


func transition(next_state: Globals.States):
	states[curr_state].exit()
	character.reset_frame()
	states[next_state].enter()
	curr_state = next_state

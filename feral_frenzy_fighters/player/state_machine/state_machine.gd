extends Node

class_name StateMachine

@export var character: PlayerCharacter
@export var curr_state: Globals.States

var past_state: Globals.States
var states: Array[State]

func init(character_to_set: PlayerCharacter):
	states = [
		AirState.new(),
		AirAttackState.new(),
		AirJumpState.new(),
		DashState.new(),
		DashAttackState.new(),
		DashJumpState.new(),
		GroundAttackState.new(),
		HitState.new(),
		IdleState.new(),
		WalkState.new(),
		WalkJumpState.new()
	]  # must be in same order as States enum in Globals.gd
	
	if character_to_set != null:
		character = character_to_set
	
	for state in states:
		state.character = character
	states[curr_state].enter()
	
	past_state = curr_state

func update(delta):
	if character.hit:
		transition(Globals.States.HIT)
	var next_state = states[curr_state].update(delta)
	# If transition, update new state instead
	# note: this implies that if a state is going to transition
	# it should return before it performs any updates
	# so that only one state is actually run per frame
	# State transitions in online games are handled by 
	# the server and are reflected in curr_state != past_state.
	# State transitions locally are otherwise handled via the 
	# next_state system.
	
	if NetworkManager.is_connected:
		if past_state != curr_state:
			transition(curr_state)
			past_state = curr_state
		else:
			states[curr_state].update(delta)
	else:
		while next_state != curr_state:
			transition(next_state)
			next_state = states[curr_state].update(delta)


func transition(next_state: Globals.States):
	states[curr_state].exit()
	character.reset_frame()
	states[next_state].enter()
	curr_state = next_state

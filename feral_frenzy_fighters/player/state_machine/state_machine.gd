extends Node

class_name StateMachine

@export var character: PlayerCharacter
@export var curr_state: Globals.States

var states: Array[State]

func init():
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
	
	for state in states:
		state.character = character
	states[curr_state].enter()

func update(delta):
	if character.hit:
		transition(Globals.States.HIT)
	if character.player_num == 0:
		print(character.velocity.x)
	var next_state = states[curr_state].update(delta)
	if character.player_num == 0:
		print(character.velocity.x)
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

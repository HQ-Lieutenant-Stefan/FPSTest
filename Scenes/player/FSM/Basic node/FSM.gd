extends Node

class_name StateMachine

@export var CURRENT_STATE: State
var PREVIOUS_STATE: State
@export var show_transition_log: bool = false
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State Mashine contains incompatible child node")
	
	await owner.ready
	CURRENT_STATE.enter()
	PREVIOUS_STATE = CURRENT_STATE

func _process(delta):
	CURRENT_STATE.update(delta)
	Global.debug.add_property("Current state", CURRENT_STATE.name, 0)
	Global.debug.add_property("Previous state", PREVIOUS_STATE.name, 1)
	
func _physics_process(delta):
	CURRENT_STATE.physics_update(delta)
	
func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	
	if new_state != null:
		if new_state != CURRENT_STATE:
			
			if show_transition_log:
				print("from " + CURRENT_STATE.name + " to " + new_state.name)
				
			CURRENT_STATE.exit()
			new_state.enter()
			PREVIOUS_STATE = CURRENT_STATE
			CURRENT_STATE = new_state
			
	else:
		push_warning("State does not exist")

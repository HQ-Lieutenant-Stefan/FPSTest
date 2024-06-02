extends Node

class_name StateMachineV3

@export var CURRENT_STATE: StateV3
@export var show_transition_log: bool = false
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is StateV3:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State Mashine contains incompatible child node")
	
	await owner.ready
	CURRENT_STATE._enter()

func _process(delta):
	CURRENT_STATE._update(delta)
	Global.debug.add_property("Current state", CURRENT_STATE.name, 0)
	
func _physics_process(delta):
	CURRENT_STATE._physics_update(delta)
	
func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	
	if new_state != null:
		if new_state != CURRENT_STATE:
			
			if show_transition_log:
				print("from " + CURRENT_STATE.name + " to " + new_state.name)
				
			CURRENT_STATE._exit()
			new_state._enter()
			CURRENT_STATE = new_state
			
	else:
		push_warning("State does not exist")

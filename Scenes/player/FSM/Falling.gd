extends PlayerMovementState
class_name Falling_P

@export var speed: float = 5.0


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	pass
	
func update(_delta: float) -> void:
	
	if PLAYER.is_on_floor():
		transition.emit("IDLE") 

extends PlayerMovementStateV3
class_name Falling_P3


func _enter() -> void:
	PLAYER.is_falling = true
	

func _update(_delta: float) -> void:
	
	if PLAYER.is_on_floor() && PLAYER.input_dir == Vector2.ZERO:
		transition.emit("IDLE")
		
	if PLAYER.is_on_floor() && PLAYER.input_dir != Vector2.ZERO:
		transition.emit("Walking")
	
func _exit() -> void:
	PLAYER.is_falling = false

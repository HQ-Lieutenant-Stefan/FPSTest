extends PlayerMovementStateV3
class_name IDLE_P3


func _enter() -> void:
	PLAYER.is_idle = true


func _update(delta: float) -> void:
	
	if PLAYER.input_dir != Vector2.ZERO && PLAYER.is_on_floor():
		transition.emit("Walking")
		
	if !PLAYER.is_on_floor():
		transition.emit("Jumping")
		
	if Input.is_action_pressed("Crounching"):
		transition.emit("Crounching")
	
	PLAYER.current_speed = lerp(PLAYER.current_speed, 0.0, PLAYER.lerp_speed * delta)


func _exit() -> void:
	PLAYER.is_idle = false

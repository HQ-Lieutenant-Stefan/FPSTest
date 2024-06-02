extends PlayerMovementStateV3
class_name Swiming_P3



func _enter() -> void:
	PLAYER.is_swiminng = true


func _physics_process(delta: float) -> void:
	
	if PLAYER.is_swiminng:
		PLAYER.current_speed = lerp(PLAYER.current_speed, PLAYER.SWIMING_SPEED, PLAYER.lerp_speed * delta)
	
	if PLAYER.has_exit_water:
		transition.emit("IDLE")

func _update(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_page_down"):
		transition.emit("IDLE")


func _exit() -> void:
	PLAYER.is_swiminng = false
	PLAYER.has_exit_water = false

extends PlayerMovementStateV3
class_name Crounching_P3


func _enter() -> void:
	PLAYER.is_crouching = true
	PLAYER.crouncing_coll.disabled = false
	PLAYER.standing_coll.disabled = true


func _update(_detla: float) -> void:
	
	
	if !Input.is_action_pressed("Crounching") && !PLAYER.under_head_check.is_colliding():
		transition.emit("IDLE")


func _physics_update(delta: float) -> void:
	PLAYER.current_speed = lerp(PLAYER.current_speed, PLAYER.CROUCHING_SPEED , PLAYER.lerp_speed * delta)
	
	PLAYER.CrouchingStart(delta)


func _exit() -> void:
	PLAYER.is_crouching = false
	PLAYER.crouncing_coll.disabled = true
	PLAYER.standing_coll.disabled = false

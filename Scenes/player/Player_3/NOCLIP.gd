extends PlayerMovementStateV3
class_name NOCLIP_V3


var speed: float


func _enter() -> void: pass


func _update(_delta: float) -> void:
	
	if !PLAYER.noclip:
		transition.emit("IDLE")


func _physics_process(delta: float) -> void:
	
	
	if PLAYER.noclip:
		speed = PLAYER.WALKING_SPEED * PLAYER.noclip_speed_mult
		
		if Input.is_action_pressed("Sprint"):
			speed *= 3.0
		
		if Input.is_action_pressed("Crounching"):
			speed /= 3.0 
		
		PLAYER.velocity = PLAYER.cam_aligned_wish_dir * speed
		PLAYER.global_position += PLAYER.velocity * delta
	
	
		PLAYER.direction = Vector3.ZERO


func _exit() -> void: pass

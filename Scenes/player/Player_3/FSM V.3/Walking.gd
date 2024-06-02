extends PlayerMovementStateV3
class_name Walking_P3

func _entered() -> void:
	PLAYER.is_walking = true

func _update(_delta: float) -> void:
	
	if PLAYER.input_dir == Vector2.ZERO:
		transition.emit("IDLE")
		
	if Input.is_action_pressed("Sprint") && PLAYER.is_on_floor() && PLAYER.input_dir != Vector2.ZERO:
		transition.emit("Sprinting")
		
	if Input.is_action_pressed("Jump") && PLAYER.can_jump():
		transition.emit("Jumping")
		
	if Input.is_action_just_pressed("Crounching"):
		transition.emit("Crounching")

func _physics_update(delta: float) -> void:
	PLAYER.current_speed = lerp(PLAYER.current_speed, PLAYER.WALKING_SPEED , PLAYER.lerp_speed * delta)
	
	# PLAYER.head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * delta

func _exit() -> void:
	PLAYER.is_walking = false

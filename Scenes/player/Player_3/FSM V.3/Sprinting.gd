extends PlayerMovementStateV3


func _enter():
	PLAYER.is_sprinting = true

func _physics_update(delta: float) -> void:
	PLAYER.current_speed = lerp(PLAYER.current_speed, PLAYER.SPRINTING_SPEED , PLAYER.lerp_speed * delta)

func _update(_delta: float):

	if Input.is_action_just_released("Sprint") && PLAYER.is_on_floor():
			transition.emit("Walking")
			
	if Input.is_action_just_pressed("Jump") && PLAYER.can_jump():
		transition.emit("Jumping")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("Falling")
	
	# SLIDING LOGIC
	if Input.is_action_just_pressed("Crounching") && PLAYER.input_dir != Vector2.ZERO && PLAYER.input_dir.y == -1:
		transition.emit("Sliding")
		
		
func _exit():
	PLAYER.is_sprinting = false

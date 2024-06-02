extends PlayerMovementState

class_name IDLE_P


func entered() -> void:
	if PLAYER.animation_player.is_playing() && PLAYER.animation_player.current_animation == "JumpEnd":
		await PLAYER.animation_player.animation_finished
		PLAYER.animation_player.pause()

func update(delta: float):
	
	
	WEAPON.sway_weapon(delta, true)
	
	
	if Input.is_action_just_pressed("Left Mouse Button"):
		WEAPON._attack()
	
	
	if (PLAYER.input_dir != Vector2.ZERO) and PLAYER.is_on_floor():
		transition.emit("Walking")
	
	if (Input.is_action_just_pressed("Jump") && PLAYER.can_jump()) || !PLAYER.is_on_floor():
		transition.emit("Jumping")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("Falling")
		
	if Input.is_action_pressed("Crounching") and PLAYER.is_on_floor():
		transition.emit("Crounching")
		
	if Input.is_action_just_pressed("Jump") && !PLAYER.under_head.is_colliding() && PLAYER.vaulting_check.is_colliding():
		transition.emit("Climbing")
		
	PLAYER.current_speed = lerp(PLAYER.current_speed, 0.0, PLAYER.lerp_speed * delta)

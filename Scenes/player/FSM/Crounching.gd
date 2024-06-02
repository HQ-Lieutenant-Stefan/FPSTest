extends PlayerMovementState

class_name Crounching_P

@export var HEAD_BOBBING_CROUCHING_SPEED = 10.0
@export var HEAD_BOBBING_CROUCHING_INTENSITY = 0.05

func enter() -> void:
	PLAYER.is_crouching = true
	
	PLAYER.current_head_bobbing_intensity = HEAD_BOBBING_CROUCHING_INTENSITY
	# PLAYER.forward_stairs_checker.shape.length = 0.25
	# PLAYER.forward_stairs_checker.position.y = .38
	
func update(delta: float) -> void:
	
	
	WEAPON.sway_weapon(delta, false)
	if PLAYER.input_dir != Vector2.ZERO:
		WEAPON.weapon_bob(delta, WEAPON.weapon_type.crounching_bob_speed, 
		WEAPON.weapon_type.crounching_Horizontal_amount, WEAPON.weapon_type.crounching_Vertical_amount)
	
		
	if PLAYER.is_sliding:
		transition.emit("Sliding")
		
	if !PLAYER.is_crouching && !PLAYER.top_head_check.is_colliding():
		transition.emit("IDLE")
		
	if Input.is_action_just_pressed("Jump") && !PLAYER.under_head.is_colliding() && PLAYER.vaulting_check.is_colliding():
			transition.emit("Climbing")
			
	if Input.is_action_just_released("Crounching") or (PLAYER.was_sliding && !PLAYER.top_head_check.is_colliding()):
		PLAYER.is_crouching = false
		PLAYER.was_sliding = false
		
func physics_update(delta: float) -> void:
	PLAYER.crouching_down(delta)
		
	PLAYER.head_bobbing_index += HEAD_BOBBING_CROUCHING_SPEED * delta
	
# func exit():
	# PLAYER.forward_stairs_checker.shape.length = 0.2
	# PLAYER.forward_stairs_checker.position.z = .33

extends PlayerMovementState

class_name Walking_P


@export var HEAD_BOBBING_WALKING_SPEED = 14.0
@export var HEAD_BOBBING_WALKING_INTENSITY = 0.1

func enter():
	PLAYER.is_walking = true
	PLAYER.current_head_bobbing_intensity = HEAD_BOBBING_WALKING_INTENSITY

func update(delta: float):
	
	
	WEAPON.sway_weapon(delta, false)
	WEAPON.weapon_bob(delta, WEAPON.weapon_type.walking_bob_speed,
	WEAPON.weapon_type.walking_Horizontal_amount, WEAPON.weapon_type.walking_Vertical_amount)
	
	
	if PLAYER.input_dir == Vector2.ZERO:
		PLAYER.is_walking = false
		transition.emit("IDLE")
		
	if Input.is_action_just_pressed("Jump") && PLAYER.can_jump():
		if !PLAYER.under_head.is_colliding() && PLAYER.forward_stairs.is_colliding():
			transition.emit("Climbing")
		else:
			transition.emit("Jumping")
			
	if !PLAYER.is_on_floor() && PLAYER.velocity.y > 0.0:
		transition.emit("Jumping")
	
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("Falling")
		
	if Input.is_action_pressed("Crounching") and PLAYER.is_on_floor():
		transition.emit("Crounching")
		
	if Input.is_action_pressed("Sprint") && PLAYER.is_on_floor() && PLAYER.input_dir != Vector2.ZERO:
		transition.emit("Sprinting")

func physics_update(delta: float) -> void:
	PLAYER.current_speed = lerp(PLAYER.current_speed, PLAYER.WALKING_SPEED , PLAYER.lerp_speed * delta)
	
	PLAYER.head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * delta

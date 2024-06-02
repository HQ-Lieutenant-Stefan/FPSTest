extends PlayerMovementState

class_name Sprinting_P

@export var HEAD_BOBBING_SPRINTING_SPEED = 22.0
@export var HEAD_BOBBING_SPRINTING_INTENSITY = 0.2

func enter():
	PLAYER.is_sprinting = true
	PLAYER.current_head_bobbing_intensity = HEAD_BOBBING_SPRINTING_INTENSITY

func physics_update(delta: float) -> void:
	PLAYER.current_speed = lerp(PLAYER.current_speed, PLAYER.SPRINTING_SPEED , PLAYER.lerp_speed * delta)
	
	PLAYER.head_bobbing_index += HEAD_BOBBING_SPRINTING_SPEED * delta

func update(delta: float):
	
	
	WEAPON.sway_weapon(delta, false)
	WEAPON.weapon_bob(delta, WEAPON.weapon_type.sprinting_bob_speed, 
	WEAPON.weapon_type.sprinting_Horizontal_amount, WEAPON.weapon_type.sprinting_Vertical_amount)
	
	
	if Input.is_action_just_pressed("Jump") && !PLAYER.under_head.is_colliding() && PLAYER.forward_stairs.is_colliding():
		transition.emit("Climbing")
		
	if !PLAYER.is_on_floor() && PLAYER.velocity.y > 0.0:
		transition.emit("Jumping")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("Falling")
			
	# SLIDING LOGIC
	if Input.is_action_just_pressed("Crounching") && PLAYER.input_dir != Vector2.ZERO && PLAYER.input_dir.y == -1:
		PLAYER.is_sliding = true
		transition.emit("Crounching")
		
	if Input.is_action_just_released("Sprint"):
		transition.emit("Walking")
		
func exit():
	PLAYER.is_sprinting = false

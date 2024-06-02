extends PlayerMovementState

class_name Jumping_P

func enter():
	PLAYER.is_jumping = true
	PLAYER.animation_player.play("JumpStart")
	

func update(_delta: float):
	if PLAYER.is_on_floor():
		PLAYER.is_jumping = false
		
	if Input.is_action_just_pressed("Jump") && !PLAYER.under_head.is_colliding() && PLAYER.forward_stairs.is_colliding():
		transition.emit("Climbing")
		
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("Falling")
		
	if !PLAYER.is_jumping:
		PLAYER.animation_player.play("JumpEnd")
		transition.emit("IDLE")

extends PlayerMovementStateV3
class_name Sliding_P3



var slide_timer: float = 0.0
var slide_speed: float = 0.0
var slide_vector: Vector2 = Vector2.ZERO




func _enter() -> void:
	slide_timer = PLAYER.slide_timer_max
	slide_speed = PLAYER.SLIDING_SPEED
	PLAYER.is_sliding = true
	PLAYER.was_sliding = false
	slide_vector = PLAYER.input_dir
	
	PLAYER.crouncing_coll.disabled = false
	PLAYER.standing_coll.disabled = true


	if PLAYER.random_slide_bobbing:
		PLAYER.slide_bobbing = PLAYER.get_random_head_bobbing()


func _physics_update(delta: float) -> void:
	
	# PLAYER.input_dir = Vector2.ZERO
	
	PLAYER.direction = (PLAYER.transform.basis * Vector3(slide_vector.x, 0,slide_vector.y)).normalized()
	PLAYER.current_speed = (slide_timer + 0.1) * slide_speed
	
	slide_timer -= delta


func _update(_delta: float) -> void:


	if Input.is_action_just_pressed("Jump") && !PLAYER.under_head_check.is_colliding():
		# PLAYER.is_sliding = false
		transition.emit("Jumping")


	if slide_timer <= 0:
		
		transition.emit("Crounching")


func _exit() -> void:
	PLAYER.is_sliding = false
	PLAYER.was_sliding = true
	
	PLAYER.crouncing_coll.disabled = true
	PLAYER.standing_coll.disabled = false

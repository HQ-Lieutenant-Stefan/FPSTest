extends PlayerMovementState

class_name Sliding_P

var rng = RandomNumberGenerator.new()

var slide_timer: float = 0.0
@export var slide_timer_max: float = 1.25
var slide_vector: Vector2 = Vector2.ZERO
@export var slide_speed: float = 10.0

func enter():
	slide_timer = slide_timer_max
	PLAYER.is_sliding = true
	slide_vector = PLAYER.input_dir
	
	if PLAYER.random_slide_bobbing:
		PLAYER.slide_bobbing = PLAYER.get_random_head_bobbing()

func physics_update(delta: float) -> void:
	
	PLAYER.input_dir = Vector2.ZERO
	
	PLAYER.direction = (PLAYER.transform.basis * Vector3(slide_vector.x, 0,slide_vector.y)).normalized()
	PLAYER.current_speed = (slide_timer + 0.1) * slide_speed
	
	slide_timer -= delta
	if slide_timer <= 0 or PLAYER.forward_stairs.is_colliding():
		PLAYER.is_sliding = false
	
func update(_delta):
	
	if Input.is_action_just_pressed("Jump"):
		PLAYER.is_sliding = false
	
	if !PLAYER.is_sliding:
		PLAYER.was_sliding = true
		transition.emit("Crounching")

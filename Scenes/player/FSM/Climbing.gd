extends PlayerMovementState

class_name Climbing_P

var has_start: bool = false
var f_pos: Vector3


var dist_to: float

func enter():
	PLAYER.is_climbing = true
	
func physics_update(_delta: float) -> void:
	
	if !has_start && PLAYER.forward_wall.is_colliding():
		f_pos = PLAYER.vaulting_check.f_pos
		dist_to = PLAYER.global_position.distance_to(f_pos)
		var diff: float = f_pos[1] - PLAYER.position.y
		has_start = !has_start
		if diff <= 3.0:
			start_vaulting()
		
	
	if PLAYER.is_on_floor():
		transition.emit("IDLE")
		
func exit():
	PLAYER.is_climbing = false
	if PLAYER.is_crouching:
		PLAYER.is_crouching = false
	has_start = !has_start
	PLAYER.first_view.rotation = Vector3.ZERO

func start_vaulting():
	PLAYER.is_climbing = true
	PLAYER.velocity = Vector3.ZERO
	PLAYER.set_process_input(false)
	
	# v_t = 0.4
	# f_t = 0.3
	var vertical_time = calc_vertical_time()
	# print(vertical_time)
	# var vertical_time = 0.35 
	var forward_time = 0.175
	
	# First Tween animation will make player move up.
	var vertical_climb = Vector3(PLAYER.global_transform.origin.x, f_pos[1], PLAYER.global_transform.origin.z)
	# var camera_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	# If your player controller's pivot is located in the middle use this:
	var vertical_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	
	vertical_tween.tween_property(PLAYER, "global_transform:origin", vertical_climb, vertical_time)
	
	#camera_tween.tween_property(PLAYER.first_view, "rotation_degrees:x", clamp(PLAYER.first_view.rotation_degrees.x - 20,-85,90), vertical_time)
	#camera_tween.tween_property(PLAYER.first_view, "rotation_degrees:z", -5.0*sign(randf_range(-10000,10000)), vertical_time)
	
	# We wait for the animation to finish.
	await vertical_tween.finished
	
	# Second Tween animation will make the player move forward where the player is facing.
	var forward = PLAYER.global_transform.origin + (-PLAYER.basis.z * 0.75)
	var forward_tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	# var camera_reset = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	forward_tween.tween_property(PLAYER, "global_transform:origin", forward, forward_time)
	
	#camera_reset.tween_property(PLAYER.first_view, "rotation_degrees:x", 0.0, forward_time)
	#camera_reset.tween_property(PLAYER.first_view, "rotation_degrees:z", 0.0, forward_time)
	
	# We wait for the animation to finish.
	await forward_tween.finished
	
	PLAYER.set_process_input(true)
	
func calc_vertical_time() -> float:
	var time = 0.35
	while fmod(time, 1.0) != 0:
		time *= 10
		dist_to *= 10
	var crounching_mod = 1.35 if PLAYER.is_crouching else 1.0
	var result = ((dist_to - fmod(dist_to, time)) / time) * 0.1 * crounching_mod
	# print(((dist_to - fmod(dist_to, time)) / time) * 0.1 * crounching_mod)
	return result

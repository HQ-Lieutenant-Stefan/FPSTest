extends CharacterBody3D
class_name Player_OLD


# PLAYER NODE
@onready var standing_collision: CollisionShape3D = $StandingCollision
@onready var crouching_collision: CollisionShape3D = $CrouchingCollision
@onready var visual: MeshInstance3D = $Visual


@onready var neck: Node3D = $neck
@onready var head: Node3D = $neck/head
@onready var eyes: Node3D = $neck/head/eyes
@onready var first_view: Camera3D = $neck/head/eyes/First_view
@onready var thrid_view: Camera3D = $neck/head/eyes/Thrid_view


@onready var left_stairs_checker: CollisionShape3D = $Left_stairs_checker
@onready var forward_stairs_checker: CollisionShape3D = $Forward_stairs_checker
@onready var right_stairs_checker: CollisionShape3D = $Right_stairs_checker


@onready var top_head_check: ShapeCast3D = $CheckArray/TopHeadCheck
@onready var forward_stairs: ShapeCast3D = $CheckArray/ForwardStairs
@onready var forward_wall: ShapeCast3D = $CheckArray/ForwardWall
@onready var under_head: ShapeCast3D = $CheckArray/UnderHead
@onready var vaulting_check: ShapeCast3D = $CheckArray/VaultingCheck
@onready var forward_push: ShapeCast3D = $CheckArray/ForwardPush


@onready var hand = $neck/head/eyes/First_view/Hand
@onready var holder = $neck/head/eyes/First_view/Holder


@onready var fsm: StateMachine = $FSM

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# MOVEMENT
var direction: Vector3
var input_dir: Vector2 =  Vector2.ZERO
var can_move: bool = true
@export var current_speed: float = 5.0

# WALKING
@export var WALKING_SPEED: float = 5.0
var is_walking: bool = false

# SPRINTING
@export var SPRINTING_SPEED: float = 8.0
var is_sprinting: bool = false

# CROUCHING
@export var CROUCHING_SPEED: float = 3.0
var crouching_depth: float = -0.5
var is_crouching: bool = false

# SLIDING
@export var SLIDING_SPEED: float = 9.0
var is_sliding: bool = false
var slide_bobbing: float = -1
@export var random_slide_bobbing: bool = true
var was_sliding: bool = false

# SLIDING DASH
var is_sliding_dash: bool = false

# JUMP
var jump_velocity: float = 4.5
var is_jumping: bool = false

# FREE LOOKING
var free_looking: bool = false
@export var free_looking_tilt_amount: float = 8.0

# HEAD BOBBING
var current_head_bobbing_intensity: float = 0.0
var head_bobbing_vector: Vector2 = Vector2.ZERO
var head_bobbing_index: float = 0.0

# LERP
var lerp_speed: float = 10.0
var air_lerp_speed: float = 3.0

# STAIRS
	# DOWN
var was_on_floor_last_frame: bool = false
var snapped_to_stairs_last_frame: bool = false
	# UP
var sep_ray_dist: float

# CLIMBING
var is_climbing: bool = false

# PICK UP OBJECT
var is_picked_up_object: bool = false

# OTHER
var rng = RandomNumberGenerator.new()
var mouse_sens: float = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Global.current_player = self
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sep_ray_dist = abs(forward_stairs_checker.position.z)
	
func _input(event):
	
	
	if Input.is_action_just_pressed("Fast exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("Change_camera"):
		if first_view.current:
			thrid_view.make_current()
		else:
			first_view.make_current()
	
	# Вращение мышкой и "Свободное вращение головой"
	if event is InputEventMouseMotion:
		mouse_movement(event)

func _physics_process(delta):
	
	Global.debug.add_property("is_picked_up_object", is_picked_up_object, 1)
	
	
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward") if can_move else Vector2.ZERO
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Handle jump.
	if Input.is_action_just_pressed("Jump") and can_jump():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if is_on_floor():
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), lerp_speed * delta)
	elif !is_on_floor() && input_dir != Vector2.ZERO:
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), air_lerp_speed * delta)
		
	get_head_tilt(input_dir, delta)
		
	get_head_bobbing(input_dir, delta)
	
	get_free_looking(delta)

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	fsm_animation(delta)
	
	
	rotate_cheker()
	
	can_step_up()
	
	
	
	move_and_slide()
	snap_down_to_stairs_check(delta)
	
	push_rigid_body(delta)
	
	
func mouse_movement(event):
	if free_looking:
			neck.rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
	else:
		rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
	head.rotate_x(-deg_to_rad(event.relative.y * mouse_sens))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func can_jump() -> bool:
	if is_on_floor() && !top_head_check.is_colliding():
		return true
	return false

func get_head_tilt(i_dir: Vector2, delta: float):
	if !is_sliding:
		if i_dir.x > 0:
			neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(-2.5), lerp_speed * delta)
		elif i_dir.x < 0:
			neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(2.5), lerp_speed * delta)
		else:
			neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(0.0), lerp_speed * delta)
		
func get_head_bobbing(i_dir: Vector2, delta: float):
	if is_on_floor() && !is_sliding && i_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (current_head_bobbing_intensity / 2.0), lerp_speed * delta)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * current_head_bobbing_intensity, lerp_speed * delta)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, lerp_speed * delta)
		eyes.position.x = lerp(eyes.position.x, 0.0, lerp_speed * delta)

func get_free_looking(delta: float):
	if (Input.is_action_pressed("Free_looking") || is_sliding) && !is_picked_up_object:
		free_looking = true
		
		if is_sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(7.0) * slide_bobbing, lerp_speed * delta)
		else:
			eyes.rotation.z = -deg_to_rad(neck.rotation.y * free_looking_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, lerp_speed * delta)
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, lerp_speed * delta)

func get_random_head_bobbing() -> int:
	var num = rng.randi_range(1, 2)
	return num if num != 2 else -1

func crouching_down(delta: float):
	
	standing_collision.disabled = true
	crouching_collision.disabled = false
	
	# current_speed
	current_speed = lerp(current_speed, CROUCHING_SPEED, lerp_speed * delta)
	# collision
	visual.position.y = lerp(visual.position.y, 0.7, lerp_speed * delta)
	visual.scale.y = lerp(visual.scale.y, 0.7, lerp_speed * delta)
	# head
	head.position.y = lerp(head.position.y, crouching_depth, lerp_speed * delta)
	top_head_check.position.y = lerp(top_head_check.position.y, 2.0 + crouching_depth, lerp_speed * delta)
	# Forward stairs
	forward_stairs.position = Vector3(0, 0.5, -1.0)
	forward_stairs.shape.height = 1.0
	forward_stairs.target_position.y = 0.0
	
func crouching_up(delta: float):
	standing_collision.disabled = false
	crouching_collision.disabled = true
	
	head.position.y = lerp(head.position.y, 0.0, lerp_speed * delta)
	top_head_check.position.y = lerp(top_head_check.position.y, 2.0, lerp_speed * delta)
		
	visual.position.y = lerp(visual.position.y, 1.0, lerp_speed * delta)
	visual.scale.y = lerp(visual.scale.y, 1.0, lerp_speed * delta)
	# Forward stairs
	forward_stairs.position.y = 1.685
	forward_stairs.shape.height = 2.0
	forward_stairs.target_position.y = -1.0

# <- Функции для спуска и подЪема по ступенькам
func snap_down_to_stairs_check(delta: float):
	var did_snap = false
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or snapped_to_stairs_last_frame):
		var body_test_result = PhysicsTestMotionResult3D.new()
		var params = PhysicsTestMotionParameters3D.new()
		var max_step_down = -0.5 # -0.35
		params.from = global_transform
		params.motion = Vector3(0, max_step_down, 0)
		if PhysicsServer3D.body_test_motion(get_rid(), params, body_test_result):
			var tranlate_y = body_test_result.get_travel().y + position.y
			position.y = lerp(position.y, tranlate_y, lerp_speed * delta)
			apply_floor_snap()
			did_snap = true
	
	was_on_floor_last_frame = is_on_floor()
	snapped_to_stairs_last_frame = did_snap

func can_step_up():
	if is_on_floor() && forward_stairs.is_colliding():
		left_stairs_checker.disabled = false
		forward_stairs_checker.disabled = false
		right_stairs_checker.disabled = false
	else:
		left_stairs_checker.disabled = true
		forward_stairs_checker.disabled = true
		right_stairs_checker.disabled = true
	
func rotate_cheker():
	
	var xz_vel = velocity * Vector3(1, 0, 1)
	var xz_f_ray_pos = xz_vel.normalized() * sep_ray_dist
	var xz_l_ray_pos = xz_f_ray_pos.rotated(Vector3(0, 1.0, 0), deg_to_rad(-50))
	var xz_r_ray_pos = xz_f_ray_pos.rotated(Vector3(0, 1.0, 0), deg_to_rad(50))
	
	forward_stairs.global_position.x = global_position.x + xz_f_ray_pos.x
	forward_stairs.global_position.z = global_position.z + xz_f_ray_pos.z
	
	forward_push.global_position.x = global_position.x + xz_f_ray_pos.x
	forward_push.global_position.z = global_position.z + xz_f_ray_pos.z
		
	forward_stairs_checker.global_position.x = global_position.x + xz_f_ray_pos.x
	forward_stairs_checker.global_position.z = global_position.z + xz_f_ray_pos.z
		
	left_stairs_checker.global_position.x = global_position.x + xz_l_ray_pos.x
	left_stairs_checker.global_position.z = global_position.z + xz_l_ray_pos.z
		
	right_stairs_checker.global_position.x = global_position.x + xz_r_ray_pos.x
	right_stairs_checker.global_position.z = global_position.z + xz_r_ray_pos.z
	
# Функции для спуска и подЪема по ступенькам ->

func push_rigid_body(dt: float):
	for col_idx in get_slide_collision_count():
		var col: KinematicCollision3D = get_slide_collision(col_idx)
		var push_force = 1.0
		if (col.get_collider() is Rigid_object_static_collision or col.get_collider() is Rigid_object_two ) && forward_push.is_colliding():
			if col.get_collider() is Rigid_object_static_collision:
				col.get_collider().push_it()
				
			if col.get_collider() is Rigid_object_two:
				# 1col.get_collider().apply_impulse(-col.get_normal() * 50 * delta, col.get_position() - col.get_collider().global_position)
				# 2 col.get_collider().apply_central_impulse(-col.get_normal() * velocity.length() * push_force) # 2
				col.get_collider().apply_central_impulse(-col.get_normal() * 25 * dt)
				# col.get_collider().apply_central_impulse(-col.get_normal() * 0.3) # 3
				# col.get_collider().apply_impulse(-col.get_normal() * 50 * delta, col.get_position()- col.get_collider().global_position)


func fsm_animation(delta: float):
	
	if is_sliding:
		crouching_down(delta)
		
		
	if !is_crouching && !top_head_check.is_colliding():
		crouching_up(delta)


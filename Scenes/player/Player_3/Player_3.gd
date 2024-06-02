extends CharacterBody3D
class_name Player_3

## Версия персонажа номер три.

# Nodes
## Текстура.
@onready var standing_mesh: MeshInstance3D = $StandingMesh

@onready var standing_coll: CollisionShape3D = $StandingColl
@onready var crouncing_coll: CollisionShape3D = $CrouncingColl


## Камера вида от превого лица.
@onready var f_view: Camera3D = $neck/head/eyes/F_view
## Камера вида от третьего лица.
@onready var t_view: Camera3D = $neck/head/eyes/T_view
var camera_list: Array[Camera3D]


@onready var _neck: Node3D = $neck
@onready var _head: Node3D = $neck/head
@onready var _eyes: Node3D = $neck/head/eyes
@onready var _camera_smooth_node: Node3D = $CameraSmoothNode


@onready var _checker: Node3D = $checker
## Чеккер для проверки коллизий над игроком.
@onready var under_head_check: ShapeCast3D = $checker/UnderHeadCheck

@onready var stairs_ahead: RayCast3D = $StairsAhead
@onready var stairs_below: RayCast3D = $StairsBelow

@onready var fsm: StateMachineV3 = $FSM



var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


# MOVEMENT
@export_category("Movement")
var direction: Vector3
## Переменная сохраняет направление передвижения игрока на основе [method Input.get_vector].[br][br]
## Если переменная равна [param Vector2.ZERO], от игрок стоит на месте.[br][br]
## Если переменная [param can_move] равна [param false], то игрок не сможет осуществлять передвижение персонажа.
var input_dir: Vector2 =  Vector2.ZERO
## Переменная отвечающая за возможность осуществлять передвижение перонажем.[br][br]
var can_move: bool = true
## Переменная хранить текущую скорость персонажа.
var current_speed: float = 0.0


var standart_standing_mesh_height: float
var crouching_standing_mesh_height: float
var mesh_position_y: float


# IDLE
var is_idle: bool = false
# WALKING
##  Скорость персонажа при обыычном передвижении.
@export var WALKING_SPEED: float = 5.0  
var is_walking: bool = false

# SPRINTING
@export var SPRINTING_SPEED: float = 8.0
var is_sprinting: bool = false

# CROUCHING
@export var CROUCHING_SPEED: float = 3.0
var is_crouching: bool = false
@export_category("Crouching Parametrs")
## Переменная отвечающая за глубину приседания игрока.
@export var crouching_depth: float = 0.5

# JUMP
@export_category("Jump Parametrs")
@export var jump_velocity: float = 4.5
@export var jump_peak_time: float = 0.5
@export var jump_fall_time: float = 0.5
@export var jump_height: float = 2.0
@export var jump_distance: float = 4.0
@export var recalculate_current_speed: bool = false
var is_jumping: bool = false
var is_falling: bool = false


# SLIDING
@export_category("Sliding Parametrs")
@export_range(1.0, 20.0, 0.01) var SLIDING_SPEED: float = 10.0
@export_range(1.0, 10.0, 0.05) var slide_timer_max: float = 1.25
var is_sliding: bool = false
var slide_bobbing: float = -1
@export var random_slide_bobbing: bool = true
var was_sliding: bool = false


# FREE LOOKING
@export_category("Free Looking")
var free_looking: bool = false
@export var free_looking_tilt_amount: float = 8.0

# CHANGE CAMERA
@export_category("Camera")
@export var Current_camera: Camera3D
var camera_index: int = 0
var max_camera_index: int

# NOCLIP
@export_category("No Clip")
var wish_dir: Vector3 = Vector3.ZERO
var cam_aligned_wish_dir: Vector3 = Vector3.ZERO
@export var noclip_speed_mult: float = 3.0
var noclip: bool = false

# SWIM
@export_category("Swim")
@export var swim_up_speed: float = 10.0
@export var SWIMING_SPEED: float = 3.5
var has_exit_water: bool = false
var is_swiminng: bool = false

# Other
var lerp_speed: float = 10.0
var air_lerp_speed: float = 3.0

var mouse_sens: float = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var jump_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var fall_gravity: float = 5.0


# uselese
var is_picked_up_object: bool = false

var max_step_height: float = 0.5
var _snapped_to_stairs_last_frame: bool = false
var _last_frame_was_on_floor = -INF


func _ready() -> void:
	
	Global.Player_V3 = self
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	_camera_smooth_node.position = _neck.position
	
	calculate_jump_parametrs()
	calculate_crouching_parametrs()
	
	prepare_crounching_shape()
	prepare_camera_list()

func _input(event) -> void:
	
	input_dir = Input.get_vector("Left", "Right", "Forward", "Backward") if can_move else Vector2.ZERO
	
	wish_dir = global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	cam_aligned_wish_dir = f_view.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	
	# Handle jump.
	if Input.is_action_just_pressed("Jump") && is_on_floor() && !under_head_check.is_colliding():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("Change_camera"):
		#if f_view.current:
			#t_view.make_current()
		#else:
			#f_view.make_current()
		change_camera()
		
	if Input.is_action_just_pressed("_NoClip") and OS.has_feature("debug"):
		_handle_noclip()
		
	if Input.is_action_just_pressed("ui_text_delete"):
		fsm.CURRENT_STATE.transition.emit("Swiming")
	
	# Вращение мышкой и "Свободное вращение головой"
	if event is InputEventMouseMotion:
		mouse_movement(event)


func _physics_process(delta: float) -> void:
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	
	Global.debug.add_property("velocity", velocity.length(), 2)
	Global.debug.add_property("free_looking", free_looking, 2)
	Global.debug.add_property("Swiminng", is_swiminng, 3)


	if not noclip:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= jump_gravity * delta

		# Add the gravity.
		if is_on_floor() or _snapped_to_stairs_last_frame:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), lerp_speed * delta)
		elif !is_on_floor() && input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), air_lerp_speed * delta)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	
	hard_code_animation(delta)
	
	get_free_looking(delta)
	
	if not _snap_up_stairs_check(delta):
		# Because _snap_up_stairs_check moves the body manually, don't call move_and_slide
		# This should be fine since we ensure with the body_test_motion that it doesn't 
		# collide with anything except the stairs it's moving up to.
		
		_push_away_rigid_bodys()
		move_and_slide()
		_snap_down_to_stairs_check()
		
	_slide_camera_smooth_back_to_origin(delta)



## Метод используется для вращения персонажа.
func mouse_movement(event) -> void:
	if free_looking:
			_neck.rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
			_neck.rotation.y = clamp(_neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
	else:
		rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
	_head.rotate_x(-deg_to_rad(event.relative.y * mouse_sens))
	_head.rotation.x = clamp(_head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

## Метод позволяет свободно вращать камерой без поворота направляния движения игрока.
func get_free_looking(delta: float) -> void:
	if (Input.is_action_pressed("Free_looking") || is_sliding) && !is_picked_up_object:
		free_looking = true
		
		if is_sliding:
			_eyes.rotation.z = lerp(_eyes.rotation.z, deg_to_rad(7.0) * slide_bobbing, lerp_speed * delta)
		else:
			_eyes.rotation.z = -deg_to_rad(_neck.rotation.y * free_looking_tilt_amount)
	else:
		free_looking = false
		_neck.rotation.y = lerp(_neck.rotation.y, 0.0, lerp_speed * delta)
		_eyes.rotation.z = lerp(_eyes.rotation.z, 0.0, lerp_speed * delta)


var _saved_camera_global_pos = null
func _save_camera_pos_for_smoothing():
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = _camera_smooth_node.global_position 
		
		
func _slide_camera_smooth_back_to_origin(delta):
	if _saved_camera_global_pos == null: return
	_camera_smooth_node.global_position.y = _saved_camera_global_pos.y
	var move_amount = max(self.velocity.length() * delta, current_speed / 2 * delta)
	_camera_smooth_node.position.y = move_toward(_camera_smooth_node.position.y, 0.0, move_amount)
	_saved_camera_global_pos = _camera_smooth_node.global_position
	if _camera_smooth_node.position.y == 0:
		_saved_camera_global_pos = null # Stop smoothing camera


func can_jump() -> bool:
	return is_on_floor() && !under_head_check.is_colliding()


func calculate_jump_parametrs() -> void:
	jump_gravity = (2 * jump_height) / pow(jump_peak_time, 2)
	fall_gravity = (2 * jump_height) / pow(jump_fall_time, 2)
	jump_velocity = jump_gravity * jump_peak_time
	if recalculate_current_speed:
		# current_speed = jump_distance / (jump_peak_time + jump_fall_time)
		WALKING_SPEED = jump_distance / (jump_peak_time + jump_fall_time)


func calculate_crouching_parametrs() -> void:
	crouching_depth *= -1
	
	standart_standing_mesh_height = standing_mesh.mesh.height
	crouching_standing_mesh_height = standart_standing_mesh_height + crouching_depth
	
	mesh_position_y = standing_mesh.position.y + crouching_depth * 0.5

func prepare_crounching_shape() -> void:
	var crounching_shape: CapsuleShape3D = CapsuleShape3D.new()
	crouncing_coll.position = standing_coll.position
	crounching_shape.height += crouching_depth
	
	crouncing_coll.disabled = true
	crouncing_coll.shape = crounching_shape
	crouncing_coll.position.y += crouching_depth * 0.5


func change_camera() -> void:
	camera_index += 1
	if camera_index >= max_camera_index:
		camera_index = 0
	camera_list[camera_index].make_current()

func prepare_camera_list() -> void:
	for elem in _eyes.get_children():
		if elem is Camera3D:
			if !elem.disable:
				camera_list.append(elem)
			
	max_camera_index = camera_list.size()
	camera_index = camera_list.bsearch(Current_camera)
	
	
func CrouchingStart(delta: float) -> void:
	standing_mesh.mesh.height = lerp(standing_mesh.mesh.height, crouching_standing_mesh_height, lerp_speed * delta)
	standing_mesh.position.y = lerp(standing_mesh.position.y, mesh_position_y, lerp_speed * delta)
	
	_head.position.y = lerp(_head.position.y, crouching_depth, lerp_speed * delta)
	_checker.position.y = lerp(_checker.position.y, crouching_depth, lerp_speed * delta)


func CrouchingEnd(delta: float) -> void:
	
	if standing_mesh.mesh.height != standart_standing_mesh_height:
		standing_mesh.mesh.height = lerp(standing_mesh.mesh.height, standart_standing_mesh_height, lerp_speed * delta)
	if standing_mesh.position.y != 1.0:
		standing_mesh.position.y = lerp(standing_mesh.position.y, 1.0, lerp_speed * delta)
		
	if _head.position.y != 0.0:
		_head.position.y = lerp(_head.position.y, 0.0, lerp_speed * delta)
		
	if _checker.position.y != 0.0:
		_checker.position.y = lerp(_checker.position.y, 0.0, lerp_speed * delta)

## Возвращает значение [param -1] или [param 1]
func get_random_head_bobbing() -> int:
	var num: int = _rng.randi_range(1, 2)
	return num if num != 2 else -1
	
	
func hard_code_animation(delta: float) -> void:
	
	if is_sliding:
		CrouchingStart(delta)
	
	if !is_crouching && !under_head_check.is_colliding():
		CrouchingEnd(delta)

# NOCLIP

func _handle_noclip() -> void:
	noclip = !noclip
	
	standing_coll.disabled = noclip

# NOCLIP

# Сраные лестницы
func is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > floor_max_angle
	
	
func _run_test_body_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(get_rid(), params, result)
	
	
func _snap_down_to_stairs_check() -> void:
	var did_snap: bool = false
	var floor_below: bool = stairs_below.is_colliding() and not is_surface_too_steep(stairs_below.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_test_body_motion(global_transform, Vector3(0, -max_step_height, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap
	
	
func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, max_step_height * 2, 0))
	# Run a body_test_motion slightly above the pos we expect to move to, towards the floor.
	#  We give some clearance above to ensure there's ample room for the player.
	#  If it hits a step <= MAX_STEP_HEIGHT, we can teleport the player on top of the step
	#  along with their intended motion forward.
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0, -max_step_height *2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > max_step_height or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > max_step_height: return false
		stairs_ahead.global_position = down_check_result.get_position() + Vector3(0, max_step_height, 0) + expected_move_motion.normalized() * 0.1
		stairs_ahead.force_raycast_update()
		if stairs_ahead.is_colliding() and not is_surface_too_steep(stairs_ahead.get_collision_normal()):
			_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

# Chfyst ktcnybws

# Функции для взаимодействия с RigidBody

func _push_away_rigid_bodys() -> void:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 5.0
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)
			

# Функции для взаимодействия с RigidBody

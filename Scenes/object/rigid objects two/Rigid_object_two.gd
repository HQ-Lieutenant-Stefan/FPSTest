extends RigidBody3D
class_name Rigid_object_two

@export_category("Rigid objects nodes")
@export var mesh: CSGMesh3D
@export var active_coll: CollisionShape3D
@export var static_coll: Rigid_object_static_collision

@export_category("DEV: Rigid objects materials")
@export var active_mesh: StandardMaterial3D
@export var static_mesh: StandardMaterial3D

@export_category("Container")
@export var is_container: bool = false
@export var is_open: bool = false
@export var lid_mesh: MeshInstance3D
@export var lid_collision: CollisionShape3D
# @export var inner_area: Area3D

@export_category("Angular / Linear velocity lerp")
@export_range(0.1, 1.0, 0.1) var linear_velocity_lerp_speed: float = 1.0
@export_range(0.1, 1.0, 0.1) var angular_velocity_lerp_speed: float = 1.0

var self_delta: float
var is_active: bool = true
var picked_up: bool = false

var keep_pos: Vector3 = Vector3.ZERO
var keep_rot: Vector3 = Vector3.ZERO
var keep_coll_layer: int = 0
var keep_coll_mask: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if active_mesh != null:
		mesh.set_material(active_mesh)
	
	static_coll.set_collision_layer(0)
	static_coll.set_collision_mask(0)
		
	if is_open:
		open_closed()

func _input(_event):
	
	if Input.is_action_pressed("ui_page_down"):
		# print(name)
		#print(linear_velocity.length())
		#print(angular_velocity.length())
		#print(linear_velocity.y)
		# print(rotation)
		# print(global_rotation)
		# print(global_rotation_degrees)
		# print(is_orbed)
		# print(linear_velocity.length() + angular_velocity.length())
		#print(collide_with_body)
		#print(is_active)
		#print(keep_pos)
		#print(static_coll.push_by_player)
		# print(linear_velocity.length() + angular_velocity.length() <= 0.04)
		pass

func _process(_delta):
	
	if picked_up:
		is_active = true
		
	static_coll.visible = false
	
	change_state()
		
func _integrate_forces(state: PhysicsDirectBodyState3D):
	self_delta = get_physics_process_delta_time()
	
	if abs(linear_velocity.y) <= 0.1 && is_active && !picked_up:
		angular_velocity = lerp(angular_velocity, Vector3.ZERO, angular_velocity_lerp_speed * self_delta)
		linear_velocity = lerp(linear_velocity, Vector3.ZERO, linear_velocity_lerp_speed * self_delta)
		
	
	# STATIC STATE KEEP THE POSITION AND ROTATION
	if !is_active:
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		global_position = keep_pos
		global_rotation = keep_rot
		

func change_state():
	# CHANGE STATE
	if angular_velocity.length() <= 0.003:
		if linear_velocity.length() <= 0.015 && !picked_up:
			is_active = false
	#if (linear_velocity.length() <= 0.015 && angular_velocity.length() <= 0.003) && linear_velocity.y <= 0.1 && !picked_up:
		#is_active = false
		
	# STATIC STATE
	if !is_active && keep_pos == Vector3.ZERO && !static_coll.push_by_player:
		if static_mesh != null:
			mesh.set_material(static_mesh)
		
		keep_pos = global_position
		keep_rot = global_rotation
		
		active_coll.disabled = true
		active_coll.visible = false
		static_coll.visible = true
		static_coll.set_collision_layer(get_collision_layer())
		static_coll.set_collision_mask(get_collision_mask())
		
		if lock_rotation == true:
			lock_rot()
	
	# ACTIVE STATE
	if (is_active && keep_pos != Vector3.ZERO) or static_coll.push_by_player:
		is_active = true
		
		if active_mesh != null:
			mesh.set_material(active_mesh)
			
		keep_pos = Vector3.ZERO
		keep_rot = Vector3.ZERO
		
		active_coll.disabled = false
		active_coll.visible = true
		static_coll.visible = false
		static_coll.set_collision_layer(0)
		static_coll.set_collision_mask(0)
		
func open_closed():
	lid_collision.disabled = !lid_collision.disabled
	lid_mesh.visible = !lid_mesh.visible
	
func lock_rot():
	lock_rotation = !lock_rotation
	
# <--- INNER AREA
func lock_in_inner_area():
	if keep_pos == Vector3.ZERO:
		keep_pos = position
	if keep_rot == Vector3.ZERO:
		keep_rot = rotation
	if keep_coll_layer == 0:
		keep_coll_layer = get_collision_layer()
		set_collision_layer(0)
	if keep_coll_mask == 0:
		keep_coll_mask = get_collision_mask()
		set_collision_mask(0)
	global_position = keep_pos
	global_rotation = keep_rot
	pass
	
func unlock_in_inner_area():
	if keep_pos != Vector3.ZERO:
		keep_pos = Vector3.ZERO
	if keep_rot != Vector3.ZERO:
		keep_rot = Vector3.ZERO
	if keep_coll_layer != 0:
		
		set_collision_layer(keep_coll_layer)
		keep_coll_layer = 0
	if keep_coll_mask != 0:
		set_collision_mask(keep_coll_mask)
		keep_coll_mask = 0
# INNER AREA --->

extends RigidBody3D
class_name Rigid_object

@onready var mesh = $Mesh  # CSGMesh3D or MeshInstance3D
@onready var coll = $coll
@onready var rigid_check = $Rigid_check

@export var static_mesh: StandardMaterial3D
@export var active_mesh: StandardMaterial3D

var self_delta: float
var pick_up: bool = false

var make_static: bool = false
var keep_pos: Vector3
var keep_rot: Vector3

var collide_with_body: bool = false

@export_range(0.01, 1.0, 0.01) var linear_velocity_lerp: float = 0.1
@export_range(0.01, 1.0, 0.01) var angular_velocity_lerp: float = 0.1

@export var is_orbed: bool = false
@export_range(0.01, 1.0, 0.01) var orbed_lerp: float = 0.1

@export_category("Collision Settings")
@export var use_static_collision: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print(0.015 * round(mass), 0.023 * round(mass))
	if rigid_check:
		if rigid_check.shape == null:
			rigid_check.set_shape(coll.shape)
		rigid_check.scale = coll.scale
		rigid_check.target_position = Vector3.ZERO
		rigid_check.set_collision_mask(0)
	
	if mesh is CSGMesh3D:
		if mesh.get_material() == null:
			mesh.set_material(active_mesh)
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _input(_event):
	
	if Input.is_action_pressed("ui_page_down"):
		# print(name)
		#print(linear_velocity.length())
		#print(angular_velocity.length())
		#print(angular_velocity.y)
		# print(rotation)
		# print(global_rotation)
		# print(global_rotation_degrees)
		# print(is_orbed)
		# print(linear_velocity.length() + angular_velocity.length())
		#print(collide_with_body)
		#print(make_static)
		# print(linear_velocity.length() + angular_velocity.length() <= 0.04)
		pass


func _process(_delta):
	
	# print(linear_velocity.length())
	# print(angular_velocity.length())
	change_mesh()
		
func _integrate_forces(state: PhysicsDirectBodyState3D):
	self_delta = get_physics_process_delta_time()
	
	if make_static:
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		global_position = keep_pos
		global_rotation = keep_rot
	
	#if !make_static:
		#state.linear_velocity = lerp(state.linear_velocity, Vector3.ZERO, linear_velocity_lerp * self_delta)
		#state.angular_velocity = lerp(state.angular_velocity, Vector3.ZERO, angular_velocity_lerp * self_delta)
		#
		#if is_orbed && angular_velocity.y <= 0.1:
			#state.angular_velocity = lerp(state.angular_velocity, Vector3.ZERO, orbed_lerp * self_delta)
			#
		#if angular_velocity.y <= 0.1:
			#state.linear_velocity = lerp(state.linear_velocity, Vector3.ZERO, linear_velocity_lerp * self_delta)
			#state.angular_velocity = lerp(state.angular_velocity, Vector3.ZERO, angular_velocity_lerp * self_delta)

func change_mesh():
	match is_orbed:
		true:
			if (linear_velocity.length() <= 0.015 * round(mass) && angular_velocity.length() <= 0.023 * round(mass)) && !make_static && !pick_up:
				if !collide_with_body:
					make_static = true
		false:
			if (linear_velocity.length() <= 0.015 * round(mass) && angular_velocity.length() <= 0.0001 * round(mass)) && !make_static && !pick_up:
				if !collide_with_body:
					make_static = true
		
	if make_static:
		if mesh is CSGMesh3D:
			mesh.set_material(static_mesh)
		
		keep_pos = global_position
		keep_rot = global_rotation
		
		if rigid_check:
			rigid_check.set_collision_mask(get_collision_layer())
		
		
	if pick_up:
		if mesh is CSGMesh3D:
			mesh.set_material(active_mesh)
		make_static = false
		
		if rigid_check:
			rigid_check.set_collision_mask(0)

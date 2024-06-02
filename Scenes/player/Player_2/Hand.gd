extends RayCast3D


@onready var holder: Marker3D = $"../Holder"
@onready var joint_3d = $"../Generic6DOFJoint3D"
@onready var player_2 = $"../../../../.."


var picked_object
var pull_power: float = 5.0
var rotation_power: float = 0.05
var rotating: bool = false
var knockback

var frozen_holder: Vector3 = Vector3.ZERO

var self_delta: float

var MESH_I: MeshInstance3D
var MSEH: Mesh
var MATERIAL: StandardMaterial3D
var albedo_color
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	
	if Input.is_action_just_pressed("ui_text_backspace"):
		picked_object.sleeping = !picked_object.sleeping
	
	if picked_object != null:
		if Input.is_action_pressed("Right click"):
			rotating = true
			player_2.set_process_input(false)
			player_2.can_move = false
			# picked_object.linear_velocity = Vector3.ZERO
			# picked_object.angular_velocity = Vector3.ZERO
			joint_3d.set_node_b(joint_3d.get_path())
			rotate_object(event)
		if Input.is_action_just_released("Right click"):
			player_2.set_process_input(true)
			player_2.can_move = true
			rotating = false
			joint_3d.set_node_b(picked_object.get_path())
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self_delta = get_physics_process_delta_time()
	
	if Input.is_action_just_pressed("PRESS E"):
		var collider = get_collider()
		if collider != null:
			if collider is Rigid_object_static_collision:
				collider = collider.get_parent()
				if collider.is_container && !collider.is_active:
					collider.open_closed()
					collider.is_open = !collider.is_open
	
	if Input.is_action_just_pressed("Interaction"):
		if picked_object == null:
			var collider = get_collider()
			if (collider is Rigid_object_static_collision or collider is Rigid_object_two) && collider.is_in_group("Grab"):
				picked_object = collider.get_parrent_node() if collider is Rigid_object_static_collision else collider
				if !picked_object.is_open:
					picked_object.picked_up = true
					picked_object.lock_rotation = false
					picked_object.add_collision_exception_with(player_2)
					# player_2.set_collision_mask_value(3, false)
					joint_3d.set_node_b(picked_object.get_path())
					player_2.is_picked_up_object = true
		elif !rotating:
			player_2.set_process_input(true)
			player_2.can_move = true
			picked_object.remove_collision_exception_with(player_2)
			# player_2.set_collision_mask_value(3, true)
			if picked_object is Rigid_object_two:
				picked_object.picked_up = false
			picked_object = null
			joint_3d.set_node_b(joint_3d.get_path())
			player_2.is_picked_up_object = false
			
	if Input.is_action_just_pressed("ui_page_up") && picked_object != null:
		knockback = picked_object.global_position - player_2.global_position
		picked_object.apply_central_impulse(knockback * 3)
		picked_object.remove_collision_exception_with(player_2)
		if picked_object is Rigid_object:
				picked_object.pick_up = false
		picked_object = null
		joint_3d.set_node_b(joint_3d.get_path())
			
	picked_object_global_transform()
			
func rotate_object(event):
	if event is InputEventMouseMotion:
		picked_object.rotate_x(deg_to_rad(event.relative.y * rotation_power))
		picked_object.rotate_y(deg_to_rad(event.relative.x * rotation_power))
			
func picked_object_global_transform():
	if picked_object is RigidBody3D:
		var a = picked_object.global_transform.origin
		var b = holder.global_transform.origin
		if a != b:
			var c = a.distance_to(b)
			var calc = (a.direction_to(b)) * pull_power * c
			picked_object.set_linear_velocity(calc)
	
			
func get_transparent():
	var XYU = picked_object.get_children()
	for node in XYU:
		if node is MeshInstance3D:
			MESH_I = node
	print(MESH_I)
	MSEH = MESH_I.mesh
	print(MSEH)
	MATERIAL = MSEH.surface_get_material(0)
	print(MATERIAL)
	albedo_color = MATERIAL.albedo_color
	print(albedo_color[3])
	
	
	

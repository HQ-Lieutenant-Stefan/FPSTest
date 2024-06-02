extends Node3D
class_name RecoilNode


@onready var parrent_node: WeaponController = $".."



var Camera: Camera3D


var recoil_amount: Vector3
var snap_amount: float
var speed: float

var current_rotation: Vector3
var target_rotation: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	Camera = parrent_node.Recoil_camera
	
	
	recoil_amount = parrent_node.weapon_type.recoil_amount
	snap_amount = parrent_node.weapon_type.recoil_snap_amount
	speed = parrent_node.weapon_type.recoil_speed
	

func _input(_event):
	
	if Input.is_action_just_pressed("Left Mouse Button"):
		add_recoil()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	Camera.basis = Quaternion.from_euler(current_rotation)
	

func add_recoil() -> void:
	target_rotation += Vector3(
		recoil_amount.x,
		randf_range(-recoil_amount.y, recoil_amount.y), 
		randf_range(-recoil_amount.z, recoil_amount.z)
	)

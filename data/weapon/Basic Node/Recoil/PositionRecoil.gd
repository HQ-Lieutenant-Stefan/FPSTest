extends Node3D

@onready var weapon: WeaponController = $".."


@export var recoil_amount: Vector3 = Vector3.ZERO
@export var snap_amount: float = 1.0
@export var speed: float = 1.0


var current_position: Vector3
var target_position: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(_event):
	
	if Input.is_action_just_pressed("Left Mouse Button"):
		add_recoil()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_position = lerp(target_position, Vector3.ZERO, speed * delta)
	target_position = lerp(current_position, target_position, snap_amount * delta)
	position = current_position
	

func add_recoil() -> void:
	target_position += Vector3(
		randf_range(recoil_amount.x, recoil_amount.x * 2.0),
		randf_range(recoil_amount.y, recoil_amount.y * 2.0), 
		randf_range(-recoil_amount.z, -recoil_amount.z / 2)
	)

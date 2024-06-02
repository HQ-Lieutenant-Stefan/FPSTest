extends Resource
# class_name Weapons

@export var name: StringName = ""
@export_category("Weapon Orientation")
@export var position: Vector3 = Vector3.ZERO
@export var rotation: Vector3 = Vector3.ZERO

@export var scale: Vector3 = Vector3(1, 1, 1)

@export_category("Weapon sway")
@export var sway_min: Vector2 = Vector2(-20.0, -20.0)
@export var sway_max: Vector2 = Vector2(20.0, 20.0)

@export_range(0, 0.2, 0.01) var sway_speed_position: float = 0.07
@export_range(0, 0.25, 0.01) var sway_amount_position: float = 0.1

@export_range(0, 0.2, 0.01) var sway_speed_rotation: float = 0.1
@export_range(0, 50, 0.1) var sway_amount_rotation: float = 30.0

@export var weapon_sway_speed: float = 1.2
@export var idle_sway_adjustmemt: float = 10.0
@export var idle_sway_rotation_strenght: float = 300.0
@export_range(0.1, 10.0, 0.1) var random_sway_amount: float = 5.0


@export_category("Visual Settings")
@export var mesh: Mesh
@export var shadow: bool = true

extends Resource
class_name Weapons

@export var name: StringName = ""
@export_category("Weapon Orientation")
@export var position: Vector3 = Vector3.ZERO
@export var rotation: Vector3 = Vector3.ZERO

@export var scale: Vector3 = Vector3(1, 1, 1)

@export_category("Weapon sway")
@export_group("Sway limit", "sway_")
@export var sway_min: Vector2 = Vector2(-20.0, -20.0)
@export var sway_max: Vector2 = Vector2(20.0, 20.0)

@export_group("Asix sway speed", "sway_speed_")
@export_range(0, 0.2, 0.01) var sway_speed_position: float = 0.07
@export_range(0, 0.2, 0.01) var sway_speed_rotation: float = 0.1

@export_group("Asix sway amount", "sway_amount_")
@export_range(0, 0.25, 0.01) var sway_amount_position: float = 0.1
@export_range(0, 50, 0.1) var sway_amount_rotation: float = 30.0


@export var weapon_sway_speed: float = 1.2
@export_group("IDLE sway", "idle_sway_")
@export var idle_sway_adjustmemt: float = 10.0
@export var idle_sway_rotation_strenght: float = 300.0
@export_range(0.1, 10.0, 0.1) var random_sway_amount: float = 5.0

@export_category("Weapon bob")
@export_group("Walking bob", "walking_")
@export var walking_bob_speed: float = 6.0
@export var walking_Horizontal_amount: float = 2.0
@export var walking_Vertical_amount: float = 1.0
@export_group("Sprinting bob", "sprinting_")
@export var sprinting_bob_speed: float = 8.0
@export var sprinting_Horizontal_amount: float = 2.5
@export var sprinting_Vertical_amount: float = 1.5
@export_group("Crounching bob", "crounching_")
@export var crounching_bob_speed: float = 2.0
@export var crounching_Horizontal_amount: float = 1.5
@export var crounching_Vertical_amount: float = 0.7


@export_category("Fire recoil")
@export var recoil_amount: Vector3 = Vector3.ZERO
@export var recoil_snap_amount: float = 1.0
@export var recoil_speed: float = 1.0


@export_category("Visual Settings")
@export var mesh: Mesh
@export var shadow: bool = true

@tool
extends Node3D
class_name WeaponController

var raycast_test = preload("res://data/weapon/Basic Node/Projectile_impact_location.tscn")


@export var weapon_type: Weapons:
	set(value):
		weapon_type = value
		if Engine.is_editor_hint():
			load_weapon()


@export var sway_noise: NoiseTexture2D
@export var sway_speed: float = 1.2
var basic_sway_speed: float = 1.2
@export var reset: bool = false:
	set(value):
		reset = value
		if Engine.is_editor_hint():
			load_weapon()
		reset = false


var current_weapon_name: StringName = ""

@onready var mesh: MeshInstance3D = %Mesh
@onready var shadow: MeshInstance3D = %Shadow

var mouse_movement: Vector2 = Vector2.ZERO

var random_sway_x: float = 1.0
var random_sway_y: float = 1.0
var random_sway_amount: float
var time: float = 0.0
var idle_sway_adjustmemt: float = 1.0
var idle_sway_rotation_strenght: float = 1.0

var weapon_bob_amount: Vector2 = Vector2.ZERO


# Recoil
@export_category("Recoil parameters")
@export var Recoil_camera: Camera3D


func _ready():
	await owner.ready
	load_weapon()


func _input(event):
	
	if event.is_action_pressed("weapon1"):
		weapon_type = load("res://data/weapon/Crowbar/crowbar.tres")
		if weapon_type:
			if current_weapon_name != weapon_type.name:
				load_weapon()
		
	if event.is_action_pressed("weapon2"):
		weapon_type = load("res://data/weapon/dev_rifleOne/Rifle.tres")
		if weapon_type:
			if current_weapon_name != weapon_type.name:
				load_weapon()
				
	if event is InputEventMouseMotion:
		mouse_movement = event.relative
		
		
	
func load_weapon() -> void:
	if weapon_type != null:
		mesh.mesh = weapon_type.mesh
		shadow.mesh = weapon_type.mesh
		
		mesh.scale = weapon_type.scale
		shadow.scale = weapon_type.scale
		
		position = weapon_type.position
		rotation_degrees = weapon_type.rotation
		
		shadow.visible = weapon_type.shadow
		
		current_weapon_name = weapon_type.name
		
		sway_speed = weapon_type.weapon_sway_speed if weapon_type.weapon_sway_speed != basic_sway_speed else basic_sway_speed
		idle_sway_adjustmemt = weapon_type.idle_sway_adjustmemt
		idle_sway_rotation_strenght = weapon_type.idle_sway_rotation_strenght
		random_sway_amount = weapon_type.random_sway_amount


func get_sway_noise() -> float:
	var player_pos: Vector3 = Vector3.ZERO
	
	if not Engine.is_editor_hint():
		player_pos = Global.current_player.global_position
		
	var noise_location: float = sway_noise.noise.get_noise_2d(player_pos.x, player_pos.y)
	return noise_location


func weapon_bob(delta: float, bob_speed: float, H_bob_amount: float, V_bob_amount: float) -> void:
	
	time += delta
	
	weapon_bob_amount.x = sin(time * bob_speed) * H_bob_amount
	weapon_bob_amount.y = absf(cos(time * bob_speed) * V_bob_amount)


func sway_weapon(delta: float, isIDLE: bool) -> void:
	
	mouse_movement = mouse_movement.clamp(weapon_type.sway_min, weapon_type.sway_max)
	
	
	if isIDLE:
		var sway_random: float = get_sway_noise()
		var sway_random_adjustmemt: float = sway_random * idle_sway_adjustmemt
		
		time += delta * (sway_speed + sway_random)
		random_sway_x = sin(time * 1.5 + sway_random_adjustmemt) / random_sway_amount
		random_sway_y = sin(time - sway_random_adjustmemt) / random_sway_amount
	

		position.x = lerp(position.x, weapon_type.position.x - (mouse_movement.x * 
		weapon_type.sway_amount_position + random_sway_x) * delta, weapon_type.sway_speed_position)
		position.y = lerp(position.y, weapon_type.position.y + (mouse_movement.y * 
		weapon_type.sway_amount_position + random_sway_y) * delta, weapon_type.sway_speed_position)
		
		rotation_degrees.y = lerp(rotation_degrees.y, weapon_type.rotation.y + (mouse_movement.x * 
	weapon_type.sway_amount_rotation + (random_sway_y * idle_sway_rotation_strenght)) * delta, weapon_type.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weapon_type.rotation.x - (mouse_movement.y * 
	weapon_type.sway_amount_rotation + (random_sway_x * idle_sway_rotation_strenght)) * delta, weapon_type.sway_speed_rotation)
	
	else:
	
		position.x = lerp(position.x, weapon_type.position.x - (mouse_movement.x * 
	weapon_type.sway_amount_position + weapon_bob_amount.x) * delta, weapon_type.sway_speed_position)
		position.y = lerp(position.y, weapon_type.position.y + (mouse_movement.y * 
	weapon_type.sway_amount_position + weapon_bob_amount.y) * delta, weapon_type.sway_speed_position)
		
		rotation_degrees.y = lerp(rotation_degrees.y, weapon_type.rotation.y + (mouse_movement.x * 
	weapon_type.sway_amount_rotation) * delta, weapon_type.sway_speed_rotation)
		rotation_degrees.x = lerp(rotation_degrees.x, weapon_type.rotation.x - (mouse_movement.y * 
	weapon_type.sway_amount_rotation) * delta, weapon_type.sway_speed_rotation)


func _attack() -> void:
	var camera = Global.current_player.first_view
	var space_state: PhysicsDirectSpaceState3D = camera.get_world_3d().direct_space_state
	var screen_center: Vector2i = get_viewport().size / 2
	var origin: Vector3 = camera.project_ray_origin(screen_center)
	var end: Vector3 = origin + camera.project_ray_normal(screen_center) * 1000
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result: Dictionary = space_state.intersect_ray(query)
	if result:
		_bullet_hole(result.get("position"), result.get("normal"))
	
	
func _bullet_hole(pos: Vector3, normal: Vector3) -> void:
	var instance: Decal = raycast_test.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = pos
	instance.look_at(instance.global_transform.origin + normal, Vector3.UP)
	if normal != Vector3.UP && normal != Vector3.DOWN:
		instance.rotate_object_local(Vector3(1, 0, 0), 90)
	await get_tree().create_timer(2).timeout
	var fade = get_tree().create_tween()
	fade.tween_property(instance, "modulate:a", 0, 1.5)
	await get_tree().create_timer(1.5).timeout
	instance.queue_free()

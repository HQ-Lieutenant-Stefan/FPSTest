@tool
extends Node3D

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
		
		
func _physics_process(delta) -> void:
	sway_weapon(delta)
	
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


func sway_weapon(delta: float) -> void:
	
	var sway_random: float = get_sway_noise()
	var sway_random_adjustmemt: float = sway_random * idle_sway_adjustmemt
	
	time += delta * (sway_speed + sway_random)
	random_sway_x = sin(time * 1.5 + sway_random_adjustmemt) / random_sway_amount
	random_sway_y = sin(time - sway_random_adjustmemt) / random_sway_amount
	
	
	
	mouse_movement = mouse_movement.clamp(weapon_type.sway_min, weapon_type.sway_max)
	
	
	position.x = lerp(position.x, weapon_type.position.x - (mouse_movement.x * 
	weapon_type.sway_amount_position + random_sway_x) * delta, weapon_type.sway_speed_position)
	position.y = lerp(position.y, weapon_type.position.y + (mouse_movement.y * 
	weapon_type.sway_amount_position + random_sway_y) * delta, weapon_type.sway_speed_position)
	
	rotation_degrees.y = lerp(rotation_degrees.y, weapon_type.rotation.y + (mouse_movement.x * 
	weapon_type.sway_amount_rotation + (random_sway_y * idle_sway_rotation_strenght)) * delta, weapon_type.sway_speed_rotation)
	rotation_degrees.x = lerp(rotation_degrees.x, weapon_type.rotation.x - (mouse_movement.y * 
	weapon_type.sway_amount_rotation + (random_sway_x * idle_sway_rotation_strenght)) * delta, weapon_type.sway_speed_rotation)
	
	#position.x = lerp(position.x, weapon_type.position.x - (mouse_movement.x * 
	#weapon_type.sway_amount_position) * delta, weapon_type.sway_speed_position)
	#position.y = lerp(position.y, weapon_type.position.y + (mouse_movement.y * 
	#weapon_type.sway_amount_position) * delta, weapon_type.sway_speed_position)
	#
	#rotation_degrees.y = lerp(rotation_degrees.y, weapon_type.rotation.y + (mouse_movement.x * 
	#weapon_type.sway_amount_rotation) * delta, weapon_type.sway_speed_rotation)
	#rotation_degrees.x = lerp(rotation_degrees.x, weapon_type.rotation.x - (mouse_movement.y * 
	#weapon_type.sway_amount_rotation) * delta, weapon_type.sway_speed_rotation)

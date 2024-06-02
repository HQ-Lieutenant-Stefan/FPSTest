extends StateV3

class_name PlayerMovementStateV3

var PLAYER: Player_3
# var WEAPON: WeaponController

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player_3
	# WEAPON = PLAYER.Weapon_Controler


func _enter() -> void:
	pass
	
func _exit() -> void:
	pass
	
func _update(_delta: float) -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
	
func _physics_update(_delta: float) -> void:
	pass

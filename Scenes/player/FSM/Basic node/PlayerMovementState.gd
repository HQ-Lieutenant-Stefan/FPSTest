extends State

class_name PlayerMovementState

var PLAYER: Player_2
var WEAPON: WeaponController

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player_2
	WEAPON = PLAYER.Weapon_Controler

func _process(_delta: float) -> void:
	pass
	

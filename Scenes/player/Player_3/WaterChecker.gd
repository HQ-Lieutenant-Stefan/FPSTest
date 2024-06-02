extends Node3D

@onready var player_3: Player_3 = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await owner.ready
	position = player_3._neck.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	


func _on_water_checker_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("water_area"):
		print("Entered")
		player_3.fsm.CURRENT_STATE.transition.emit("Swiming")


func _on_water_checker_area_area_exited(area: Area3D) -> void:
	if area.is_in_group("water_area"):
		print("Exited")
		player_3.has_exit_water = true

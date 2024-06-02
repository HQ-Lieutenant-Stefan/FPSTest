extends PlayerMovementStateV3
class_name Jumping_P3

func _enter() -> void:
	PLAYER.is_jumping = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _update(_delta: float) -> void:
	
	if PLAYER.is_on_floor():
		PLAYER.is_jumping = false
	
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("Falling")
		
	if !PLAYER.is_jumping && PLAYER.input_dir == Vector2.ZERO && PLAYER.is_on_floor():
		transition.emit("IDLE")
	
	if !PLAYER.is_jumping && PLAYER.input_dir != Vector2.ZERO && PLAYER.is_on_floor():
		transition.emit("Walking")
		
	if PLAYER.noclip:
		transition.emit("NOCLIP")


func _exit() ->  void:
	PLAYER.is_jumping = false

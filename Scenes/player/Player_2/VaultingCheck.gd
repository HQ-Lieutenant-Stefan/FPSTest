extends ShapeCast3D

var f_pos: Vector3

func _physics_process(_delta):
	
	if is_colliding():
		f_pos = get_collision_point(0)

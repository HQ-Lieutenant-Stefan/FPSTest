extends RayCast3D

@onready var stomach = $".."

var default_y: float
var new_y: float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if stomach.is_colliding():
		var coll: Object = stomach.get_collider(0)
		if coll.get("size") != null:
			new_y = coll.size.y * coll.scale.y
				
		if is_colliding():
			translate_object_local(Vector3(0, 0.1, 0))
		
	elif !stomach.is_colliding():
		position = Vector3(0, 0, 0)

func get_new_height():
	if !is_colliding():
		return new_y
	return false

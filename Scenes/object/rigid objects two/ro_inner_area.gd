extends Area3D
class_name RO_inner_area

@export var source_area: CollisionShape3D
var inner_coll: CollisionShape3D = CollisionShape3D.new()
var parent_node: Rigid_object_two

var inner_object: Array[Rigid_object_two]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	add_child(inner_coll)
	parent_node = get_parent_node_3d()
	
	inner_coll.shape = source_area.shape
	inner_coll.scale = source_area.scale - Vector3(0.01, 0.01, 0.01)
	set_collision_mask(parent_node.get_collision_layer())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

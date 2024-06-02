extends StaticBody3D
class_name Rigid_object_static_collision

@export_category("Parent node")
@export var parent_node: Rigid_object_two

var push_by_player: bool = false
var timer: Timer = Timer.new()
var timer_start: bool = false

@export_range(0.1, 10.0) var sleep_time: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if parent_node == null:
		parent_node = get_parrent_node()
	
	for group in parent_node.get_groups():
		add_to_group(group)
	
	add_child(timer)
	timer.one_shot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	#if timer.is_stopped():
		#push_by_player = false
		#parent_node.lock_rotation = false
	#
	if push_by_player && !timer_start:
		timer.start(sleep_time)
		timer_start = true
		
	if timer.is_stopped():
		timer_start = false
		push_by_player = false
		
	if parent_node.lock_rotation == false && push_by_player:
		parent_node.lock_rot()
		
	if Input.is_action_just_pressed("ui_page_down"):
		print("timer_start: ", timer_start)
		print("push_by_player: ", push_by_player)
		print("parent_node.lock_rotation: ", parent_node.lock_rotation)
		
	if Input.is_action_just_pressed("ui_page_up"):
		parent_node.lock_rot()
	
func get_parrent_node():
	return parent_node

func push_it():
	push_by_player = true

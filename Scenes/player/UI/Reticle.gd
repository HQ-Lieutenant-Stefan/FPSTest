extends CenterContainer

@export var Dot_radius: float = 1.0
@export var Dot_color: Color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _draw():
	draw_circle(Vector2(0, 0), Dot_radius, Dot_color)

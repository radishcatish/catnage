extends Camera2D
var target: Vector2
var speed: float = .5

func _physics_process(_d):
	position.x = lerp(position.x, target.x, speed)
	position.y = lerp(position.y, target.y, speed)


func teleport(pos):
	position = pos
	target = pos

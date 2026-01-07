extends AnimatedSprite2D
@onready var main: CharacterBody2D = $".."


@onready var dir = I.d.x
func _process(_d):
	if main.last_on_floor <= 5:
		dir = I.d.x if I.d.x != 0 else dir
	else:
		dir = sign(main.last_wall_normal) if main.last_on_wall <= 5 else dir
		print(sign(main.last_wall_normal))
	flip_h = false if dir == 1 else true
	Camera.target = global_position

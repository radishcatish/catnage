extends AnimatedSprite2D
@onready var main: CharacterBody2D = $".."


@onready var dir = I.d.x
func _process(_d):
	if main.last_on_floor <= 5:
		dir = I.d.x if I.d.x != 0 else dir
	else:
		dir = sign(main.last_wall_normal) if main.last_on_wall <= 5 else dir
	flip_h = false if dir == 1 else true
	Camera.target = global_position
	
	match main.state:
		main.PlayerState.GENERAL:
			if main.is_on_floor():
				if abs(main.velocity.x) > 300:
					play("run", abs(main.velocity.x) / 600)
				elif abs(main.velocity.x) > 10:
					play("walk")
				else:
					play("idle")
			else:
				if main.velocity.y > 0:
					play("midair")
					frame = 1
				else:
					play("midair")
					frame = 0

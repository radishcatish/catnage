extends AnimatedSprite2D
@onready var witz: CharacterBody2D = $"../Witz"

func _physics_process(delta: float) -> void:
	flip_h = not bool((sign(witz.position.x - position.x ) + 1) * -1)
	var lerp_pos = lerp(position, witz.position + Vector2(witz.visual_dir * -50, -110), delta * 5)
	position = lerp_pos
	rotation_degrees = (lerp_pos.x - position.x) / 2

	#scale.y = clamp(remap(lerp_pos.y - position.y, -10, 10, .5, 1.5), .5, 1.1)
	#scale.x = clamp(remap(lerp_pos.y - position.y, -10, 10, 1.5, .5), .5, 1.1)
	
	
		
	

extends AnimatedSprite2D
@onready var witz: CharacterBody2D = $"../Witz"
var tmr: int = 0
func _physics_process(delta: float) -> void:
	tmr += 1
	position = lerp(position, witz.position + Vector2(witz.visual_dir * -50, -110), delta * 5)
	
	if tmr % 10 == 0:
		flip_h = not bool((sign(witz.position.x - position.x ) + 1) * -1)
	

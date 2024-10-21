extends Sprite2D

func _process(delta: float) -> void:
	
	offset.y -= 13 * delta 
	while offset.y <= -64:
		offset.y += 64

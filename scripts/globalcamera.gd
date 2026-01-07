extends Camera2D

var target: Vector2
var speed: float = 1
var playermode: bool = false
var deadzone: Vector2 = Vector2(0, 0)
var lookahead: int = 50
var lookahead_pos: int = 0
func _physics_process(_delta):
	if playermode:
		_update_player_mode()
	else:
		position = position.lerp(target, speed)

func _update_player_mode():
	if not target:
		return
	var offset2 = target - position
	if offset2.x > deadzone.x:
		position.x = lerp(position.x, target.x - deadzone.x, speed)
	elif offset2.x < -deadzone.x:
		position.x = lerp(position.x, target.x + deadzone.x, speed)
	if offset2.y > deadzone.y:
		position.y = lerp(position.y, target.y - deadzone.y, speed)
	elif offset2.y < -deadzone.y:
		position.y = lerp(position.y, target.y + deadzone.y, speed)

	if DisplayServer.window_get_size().x > 2000:
		get_window().content_scale_factor = 2.0
	else:
		get_window().content_scale_factor = 1.0
	lookahead_pos = lerpf(lookahead_pos, lookahead * I.d.x, .1)

	position.x += lookahead_pos


func teleport(pos: Vector2):
	position = pos
	target = pos

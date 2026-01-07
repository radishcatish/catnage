extends Actor
@onready var sprite: AnimatedSprite2D = $Sprite
var last_on_floor := 10
var last_off_floor := 10
var last_on_wall := 10
var last_wall_normal := 0.0
enum PlayerState {GENERAL}
var state := PlayerState.GENERAL
func _physics_process(_d):
	last_on_floor = 0 if is_on_floor() else last_on_floor + 1
	last_off_floor = 0 if not is_on_floor() else last_off_floor + 1
	last_on_wall = 0 if is_on_wall_only() else last_on_wall + 1
	last_wall_normal = get_wall_normal().x if get_wall_normal().x != 0 else last_wall_normal

	if I.last_z_press <= 5:
		if last_on_floor < 5:
			velocity.y = -1000
			last_on_floor = 6
		if last_on_wall <= 5:
			velocity.y = -1000
			velocity.x = sign(last_wall_normal) * 700
			sprite.dir = sign(last_wall_normal)
			last_on_wall = 6

	if I.shift_pressed:
		var target_speed = I.d.x * 600
		if abs(velocity.x) < abs(target_speed) or sign(velocity.x) != sign(target_speed):
			velocity.x = move_toward(velocity.x, target_speed, 80)
	else:
		velocity.x = move_toward(velocity.x, I.d.x * 300, 80)
	velocity.y += 60 - (int(I.z_pressed) * 20)
	velocity.y = -200.0 if I.last_z_release == 1 and velocity.y < -200.0 else velocity.y
	move_and_slide()

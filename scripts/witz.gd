extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $Sprite

var old_wall_normal: float = 0.0
var wall_normal:     float = 0.0
var extra_speed:     float = 0.0

var last_on_floor:   int = 0
var last_on_wall:    int = 0
var visual_dir:      int = 1

const WALK_ACCEL = 100.0
const AIR_ACCEL = 50.0
const MAX_SPEED = 500.0
const FRICTION = 100.0
const JUMP_VELOCITY = -1000.0
func _physics_process(_delta: float) -> void:
	var direction := int(Input.get_axis("left", "right"))
	var accel = WALK_ACCEL if is_on_floor() else AIR_ACCEL
	last_on_floor = last_on_floor + 1 if not is_on_floor() else 0
	last_on_wall = last_on_wall + 1 if not is_on_wall() else 0
	extra_speed = 500 if Input.is_action_pressed("shift") else 0
	visual_dir = direction if direction != 0 else visual_dir
	if is_on_floor():
		old_wall_normal = 0
		wall_normal = 0
	else:
		old_wall_normal = get_wall_normal().x

	if Input.is_action_just_pressed("z"):
		if last_on_wall < 11 and not is_on_floor() and old_wall_normal != wall_normal:
			velocity.x += sign(old_wall_normal) * 1200
			velocity.y = JUMP_VELOCITY
			wall_normal = old_wall_normal
		if last_on_floor < 5:
			velocity.y += JUMP_VELOCITY
			last_on_floor = 5	
	velocity.y += (60 - (int(Input.is_action_pressed("z")) * 20))
	velocity.y = -200.0 if Input.is_action_just_released("z") and velocity.y < -200.0 else velocity.y
	velocity.x = move_toward(velocity.x, direction * (MAX_SPEED + extra_speed), accel)
	move_and_slide()
	sprite.flip_h = false if visual_dir == 1 else true
	sprite.skew = lerp(sprite.rotation_degrees, clamp(velocity.x / 100.0, -18.0, 18.0), 0.2) / 15

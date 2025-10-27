extends CharacterBody2D
@warning_ignore_start("narrowing_conversion")
@warning_ignore_start("incompatible_ternary")
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera2D
var last_on_floor:           int = 10
var last_on_wall:            int = 10
var last_z_press:            int = 10
var last_x_press:            int = 10
var last_c_press:            int = 10
var last_shift_press:        int = 10
var last_up_press:           int = 10
var last_left_press:         int = 10
var last_right_press:        int = 10
var visual_dir:      int = 1
var extra_speed:     float = 0.0
var old_wall_normal: float = 0.0
var wall_normal:     float = 0.0
var lock_dir:  bool = false
var lock_slow: bool = false
var lock_movement: bool = false
const WALK_ACCEL = 100.0
const AIR_ACCEL = 60.0
const MAX_SPEED = 500.0
const FRICTION = 100.0
const JUMP_VELOCITY = -1000.0
enum PlayerState {GENERAL, JAB}
var State := PlayerState.GENERAL
var AltState: int = 0
func _physics_process(_delta: float) -> void:
	var direction := int(Input.get_axis("left", "right")) if not lock_movement else 0
	var accel = WALK_ACCEL if is_on_floor() else AIR_ACCEL
	last_on_floor = last_on_floor + 1 if not is_on_floor() else 0
	last_on_wall = last_on_wall + 1 if not is_on_wall() else 0
	last_z_press = last_z_press + 1 if not Input.is_action_just_pressed("z") else 0
	last_x_press = last_x_press + 1 if not Input.is_action_just_pressed("x") else 0
	last_c_press = last_c_press + 1 if not Input.is_action_just_pressed("c") else 0
	extra_speed = 500 if Input.is_action_pressed("shift") else 0
	if not lock_dir:
		visual_dir = direction if direction != 0 and last_on_floor < 2 else visual_dir

	if is_on_floor():
		old_wall_normal = 0
		wall_normal = 0
	else:
		old_wall_normal = get_wall_normal().x

		
	if last_z_press < 4 and not lock_movement:
		last_z_press = 4
		if last_on_wall < 10 and not last_on_floor < 7 and old_wall_normal != wall_normal:
			velocity.x += sign(old_wall_normal) * 1200
			velocity.y = JUMP_VELOCITY
			last_on_wall = 10
			wall_normal = old_wall_normal
			if not lock_dir:
				visual_dir = wall_normal
		if last_on_floor < 5:
			velocity.y += JUMP_VELOCITY
			last_on_floor = 5
	
	# wall sliding
	#velocity.y *= .9 if is_on_wall() and old_wall_normal != wall_normal and velocity.y > 0 else 1.0
	
	# variable jump height (gravity)
	velocity.y += (60 - (int(Input.is_action_pressed("z")) * 20))
	
	# variable jump height 2 (instant stop)
	velocity.y = -200.0 if Input.is_action_just_released("z") and velocity.y < -200.0 else velocity.y
	
	# main movement
	if not lock_movement:
		if direction:
			velocity.x = move_toward(velocity.x, direction * (MAX_SPEED + extra_speed), accel)
		else:
			velocity.x = move_toward(velocity.x, 0, accel / 4)
	else:
		velocity.x = move_toward(velocity.x, 0, accel / 4)
	
	
	
	move_and_slide()
	
	
	
	if is_on_floor() and last_x_press < 3:
		State = PlayerState.JAB
		sprite.play("jab")
		lock_dir = true
		lock_movement = true
		await sprite.animation_finished
		lock_dir = false
		lock_movement = false
		State = PlayerState.GENERAL
	
	

	
	sprite.flip_h = false if visual_dir == 1 else true
	sprite.rotation_degrees = lerpf(0, clamp(velocity.x / 100, -18, 18), 1.5) if not is_on_floor() else 0
	print(velocity.x)
	match State:
		PlayerState.GENERAL:
			if is_on_floor():
				if direction or abs(velocity.x) > 22:
					if abs(velocity.x) > 500:
						sprite.play("run", self.velocity.x / 1000)
					else:
						sprite.play("walk", self.velocity.x / 500)
					if ((visual_dir == 1 and velocity.x < 0) or (visual_dir == -1 and velocity.x > 0) ) and abs(velocity.x) > 22:
						sprite.play("skid")
						
						
				else:
					sprite.play("idle")
				if not direction and Input.is_action_pressed("down"):
					sprite.play("crouch")
			else:
				sprite.play("midair")
				if sprite.animation == "midair":
					var t = clamp((velocity.y + 20.0) / 500.0, 0.0, 1.0)
					sprite.frame = int(t * 3.999)

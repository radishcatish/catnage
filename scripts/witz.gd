extends CharacterBody2D
@warning_ignore_start("narrowing_conversion")
@warning_ignore_start("incompatible_ternary")
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera2D
@onready var swish_1: AudioStreamPlayer = $Sounds/swish1
@onready var swish_2: AudioStreamPlayer = $Sounds/swish2
@onready var whip_1: AudioStreamPlayer = $Sounds/whip1
@onready var whip_2: AudioStreamPlayer = $Sounds/whip2
@onready var step_1: AudioStreamPlayer = $Sounds/step1
@onready var step_2: AudioStreamPlayer = $Sounds/step2
@onready var jump_1: AudioStreamPlayer = $Sounds/jump1
@onready var jump_2: AudioStreamPlayer = $Sounds/jump2
@onready var jump_3: AudioStreamPlayer = $Sounds/jump3

var last_on_floor:            int = 10
var last_off_floor:           int = 10
var last_on_wall:             int = 10
var last_z_press:             int = 10
var last_x_press:             int = 10
var last_c_press:             int = 10
var last_shift_press:         int = 10
var last_up_press:            int = 10
var last_left_press:          int = 10
var last_right_press:         int = 10
var visual_dir:               int = 1
var extra_speed:              float = 0.0
var old_wall_normal:          float = 0.0
var wall_normal:              float = 0.0
var lock_dir:                 bool = false
var lock_slow:                bool = false
var lock_movement:            bool = false
var health:                   int = 8
const WALK_ACCEL = 100.0
const AIR_ACCEL = 60.0
const MAX_SPEED = 500.0
const FRICTION = 100.0
const JUMP_VELOCITY = -1000.0
enum PlayerState {GENERAL, ATTACKING}
var State := PlayerState.GENERAL
enum Attacks {NONE, JAB, UPGROUND, FAIR, BAIR, UAIR, DAIR, NAIR}
var AttackState := Attacks.NONE
var AltAttackState: int = 0
func _physics_process(_delta: float) -> void:
	var direction := int(Input.get_axis(&"left", &"right")) if not lock_movement else 0
	var accel = WALK_ACCEL if is_on_floor() else AIR_ACCEL
	State = PlayerState.ATTACKING if AttackState != Attacks.NONE else State
	last_on_floor = last_on_floor + 1 if not is_on_floor() else 0
	last_off_floor = last_off_floor + 1 if is_on_floor() else 0
	last_on_wall = last_on_wall + 1 if not is_on_wall() else 0
	last_z_press = last_z_press + 1 if not Input.is_action_just_pressed(&"z") else 0
	last_x_press = last_x_press + 1 if not Input.is_action_just_pressed(&"x") else 0
	last_c_press = last_c_press + 1 if not Input.is_action_just_pressed(&"c") else 0
	extra_speed = 500 if not Input.is_action_pressed(&"shift") else 0
	if not lock_dir or State == PlayerState.ATTACKING:
		visual_dir = direction if direction != 0 and last_on_floor < 2 else visual_dir
	if is_on_floor():
		old_wall_normal = 0
		wall_normal = 0
	else:
		old_wall_normal = get_wall_normal().x
	
	if last_off_floor == 1:
		stepsound()
		
	if last_z_press < 4 and not lock_movement:
		last_z_press = 4
		if last_on_wall < 10 and not last_on_floor < 7 and old_wall_normal != wall_normal:
			velocity.x += sign(old_wall_normal) * 1200
			velocity.y = JUMP_VELOCITY
			last_on_wall = 10
			wall_normal = old_wall_normal
			if not lock_dir:
				visual_dir = wall_normal
			jumpsound()
			stepsound()
		if last_on_floor < 5:
			velocity.y += JUMP_VELOCITY - abs(velocity.x) / 10
			last_on_floor = 5
			jumpsound()
	
			
	
	# wall sliding
	#velocity.y *= .9 if is_on_wall() and old_wall_normal != wall_normal and velocity.y > 0 else 1.0
	
	# variable jump height (gravity)
	velocity.y += (60 - (int(Input.is_action_pressed(&"z")) * 20))
	
	# variable jump height 2 (instant stop)
	velocity.y = -200.0 if Input.is_action_just_released(&"z") and velocity.y < -200.0 else velocity.y
	
	# main movement
	if not lock_movement:
		if direction:
			velocity.x = move_toward(velocity.x, direction * (MAX_SPEED + extra_speed), accel)
		else:
			velocity.x = move_toward(velocity.x, 0, accel / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, accel / 2)
	
	move_and_slide()
	
	
	if Input.is_action_just_pressed(&"x"):
		attack_handler()
	
	sprite.flip_h = false if visual_dir == 1 else true
	sprite.rotation_degrees = lerpf(0, clamp(velocity.x / 100, -18, 18), 1.5) if not is_on_floor() else 0

	match State:
		PlayerState.GENERAL:
			if is_on_floor():
				if direction or abs(velocity.x) > 22:
					if abs(velocity.x) > 500:
						sprite.play(&"run", self.velocity.x / 1000)
					else:
						sprite.play(&"walk", self.velocity.x / 500)
					if ((visual_dir == 1 and velocity.x < 0) or (visual_dir == -1 and velocity.x > 0) ) and abs(velocity.x) > 22:
						sprite.play(&"skid")
				else:
					sprite.play(&"idle")
				if not direction and Input.is_action_pressed(&"down"):
					sprite.play(&"crouch")
			else:
				sprite.play(&"midair")
				if sprite.animation == &"midair":
					var t = clamp((velocity.y + 20.0) / 500.0, 0.0, 1.0)
					sprite.frame = int(t * 3.999)
		PlayerState.ATTACKING:
			if is_on_floor() and not AttackState in [Attacks.JAB, Attacks.UPGROUND, Attacks.NONE]:
				AttackState = Attacks.NONE
				State = PlayerState.GENERAL
				
#region extra functions
func attack_handler():
	if State == PlayerState.ATTACKING:
		return
	var dir := int(Input.get_axis(&"left", &"right"))
	var vdir := int(Input.get_axis(&"up", &"down"))
	State = PlayerState.ATTACKING
	if is_on_floor():
		lock_movement = true
		if not Input.is_action_pressed(&"up"):
			AttackState = Attacks.JAB
			sprite.play(&"jab")
			await sprite.frame_changed
			spawn_hitbox(10, Vector2(visual_dir, 0), Vector2(visual_dir * 40, -30), Vector2(80,50), .1, .5, 1)
		else:
			AttackState = Attacks.JAB
			sprite.play(&"upground")
			spawn_hitbox(10, Vector2(float(-visual_dir) / 4, -1), Vector2(-visual_dir * 10, -80), Vector2(50,80), .1, .5, 1)
	else:
		if dir == 0 and vdir == 0:
			AttackState = Attacks.NAIR
			sprite.play(&"neutralair")
			spawn_hitbox(7, Vector2(0, 0), Vector2(0, -40), Vector2(80,80), .1, .5, 1)
		elif vdir == 1:
			AttackState = Attacks.DAIR
			sprite.play(&"downair")
			spawn_hitbox(10, Vector2(0, 1), Vector2(0, 0), Vector2(40,50), .1, .5, 1)
		elif vdir == -1:
			AttackState = Attacks.UAIR
			sprite.play(&"upair")
			spawn_hitbox(10, Vector2(0,-1), Vector2(0, -80), Vector2(50,80), .1, .5, 1)
		elif dir and dir != -visual_dir:
			AttackState = Attacks.FAIR
			sprite.play(&"forwardair")
			spawn_hitbox(10, Vector2(visual_dir, 0), Vector2(visual_dir * 50, -30), Vector2(80,50), .1, .5, 1)
		elif dir == -visual_dir:
			AttackState = Attacks.BAIR
			sprite.play(&"backair")
			spawn_hitbox(10, Vector2(-visual_dir, 0), Vector2(visual_dir * -50, -30), Vector2(80,50), .1, .5, 1)

	await sprite.animation_finished
	lock_movement = false
	AttackState = Attacks.NONE
	State = PlayerState.GENERAL



func _on_sprite_frame_changed() -> void:
	
	if sprite.animation == "run":
		if sprite.frame == 1:
			step_1.play()
		if sprite.frame == 4:
			step_2.play()
	if sprite.animation == "walk":
		if sprite.frame == 1:
			step_1.play()
		if sprite.frame == 3:
			step_2.play()
			

	if sprite.animation in [&"backair", &"downair", &"forwardair", &"neutralair"]:
		if sprite.frame == 1:
			swishsound()
				
	if sprite.animation in [&"upair", &"upground", &"neutralair", &"jab"]:
		if sprite.frame == 1:
			whipsound()
			
const HITBOX = preload("res://scenes/hitbox.tscn")
func spawn_hitbox(ticks:int,angle:Vector2,pos:Vector2,size:Vector2,knockback:float,damage:float,power:int):
	var hitbox = HITBOX.duplicate().instantiate()
	hitbox.player = true
	hitbox.size = size
	hitbox.position = pos
	hitbox.ticks = ticks
	hitbox.angle = angle
	hitbox.knockback = knockback
	hitbox.damage = damage
	hitbox.power = power
	add_child(hitbox)
	

#region sound functions
func jumpsound():
	if randf() < .5:
		jump_1.pitch_scale = randf_range(.9, 1.1)
		jump_1.play()
	elif randf() < .5:
		jump_2.pitch_scale = randf_range(.9, 1.1)
		jump_2.play()
	else:
		jump_3.pitch_scale = randf_range(.9, 1.1)
		jump_3.play()
func stepsound():
	if randf() < .5:
		step_1.pitch_scale = randf_range(.9, 1.1)
		step_1.play()
	else:
		step_2.pitch_scale = randf_range(.9, 1.1)
		step_2.play()

func swishsound():
	if randf() < .5:
		swish_1.pitch_scale = randf_range(.9, 1.1)
		swish_1.play()
	else:
		swish_2.pitch_scale = randf_range(.9, 1.1)
		swish_2.play()
		
func whipsound():
	if randf() < .5:
		whip_1.pitch_scale = randf_range(.9, 1.1)
		whip_1.play()
	else:
		whip_2.pitch_scale = randf_range(.9, 1.1)
		whip_2.play()
		
#endregion
#endregion

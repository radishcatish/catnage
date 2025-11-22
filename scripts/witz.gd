extends CharacterBody2D
@warning_ignore_start("narrowing_conversion")
@warning_ignore_start("incompatible_ternary")
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera2D
@onready var hitboxes: Node2D = $Hitboxes
@onready var swish_1: AudioStreamPlayer = $Sounds/swish1
@onready var swish_2: AudioStreamPlayer = $Sounds/swish2
@onready var whip_1: AudioStreamPlayer = $Sounds/whip1
@onready var whip_2: AudioStreamPlayer = $Sounds/whip2
@onready var step_1: AudioStreamPlayer = $Sounds/step1
@onready var step_2: AudioStreamPlayer = $Sounds/step2
@onready var jump_1: AudioStreamPlayer = $Sounds/jump1
@onready var jump_2: AudioStreamPlayer = $Sounds/jump2
@onready var jump_3: AudioStreamPlayer = $Sounds/jump3
@onready var squeak: AudioStreamPlayer = $Sounds/Squeak

const WALK_ACCEL = 100.0
const AIR_ACCEL = 60.0
const MAX_SPEED = 300.0
const JUMP_VELOCITY = -1000.0

enum PlayerState { GENERAL, ATTACKING, OUCH }
enum Attacks { NONE, JAB, UPGROUND, FAIR, BAIR, UAIR, DAIR, NAIR }

var State := PlayerState.GENERAL
var AttackState := Attacks.NONE
var stun := 0
var iframes := 1
var lock_move := false
var lock_dir := false
var visual_dir := 1
var extra_speed := 0.0
var last_on_floor := 10
var last_off_floor := 10
var last_on_wall := 10
var last_z_press := 10
var last_x_press := 10
var wall_touch_timer := 0
var current_wall_normal := 0
var last_wall_jump_normal := 999
var current_attack_anim: String = ""
var dir := 0

func _ready():
	sprite.connect("animation_finished", Callable(self, "_animation_finished"))
	sprite.connect("frame_changed", Callable(self, "_frame_changed"))



func _process(_delta):
	if Engine.get_frames_drawn() % 2 == 0 and iframes > 1:
		sprite.visible = !sprite.visible
	else:
		sprite.visible = true
		
func _physics_process(_d):
	misc()
	handle_movement()
	update_animation()
	apply_state_logic()
	
	move_and_slide()
	
func misc():
	sprite.flip_h = (visual_dir == -1)
	dir = int(Input.get_axis("left", "right")) if not lock_move else 0
	extra_speed = 500 if not Input.is_action_pressed("shift") else 0
	stun = max(stun - 1, 0)
	iframes = max(iframes - 1, 0)
	last_on_floor = 0 if is_on_floor() else last_on_floor + 1
	last_off_floor = 0 if not is_on_floor() else last_off_floor + 1
	last_on_wall = 0 if is_on_wall() else last_on_wall + 1
	last_z_press = 0 if Input.is_action_just_pressed("z") else last_z_press + 1
	last_x_press = 0 if Input.is_action_just_pressed("x") else last_x_press + 1
	
	if is_on_wall_only():
		current_wall_normal = get_wall_normal().x
		wall_touch_timer = 8
	else:
		wall_touch_timer = max(wall_touch_timer - 1, 0)
		current_wall_normal = 0
		if is_on_floor():
			last_wall_jump_normal = 0

	if Input.is_action_just_pressed("x"):
		attack_handler()

func handle_movement():
	var accel = WALK_ACCEL if is_on_floor() else AIR_ACCEL
	
	if stun <= 0 and (not lock_move or not is_on_floor()):
		if dir != 0:
			velocity.x = move_toward(velocity.x, dir * (MAX_SPEED + extra_speed), accel)
		else:
			velocity.x = move_toward(velocity.x, 0, accel / 2)
	else:
		velocity.x = move_toward(velocity.x, 0, accel / 6)
	
	
	if last_z_press <= 5 and not lock_move:
		if last_on_floor < 5:
			velocity.y += JUMP_VELOCITY - abs(velocity.x) / 10
			last_on_floor = 5
			jumpsound()
		if last_on_wall <= 5 and last_on_floor > 7 and (last_wall_jump_normal != current_wall_normal or (current_wall_normal == 0 and last_wall_jump_normal == 0)):
			velocity.x += sign(current_wall_normal) * 1200
			velocity.y = JUMP_VELOCITY
			last_on_wall = 10
			last_wall_jump_normal = current_wall_normal
			if not lock_dir:
				visual_dir = current_wall_normal
			jumpsound()
			stepsound()
		last_z_press = 6

	velocity.y += (60 - (int(Input.is_action_pressed("z")) * 20))
	if Input.is_action_just_released("z") and velocity.y < -200:
		velocity.y = -200

	


func attack_handler():
	if State == PlayerState.ATTACKING or State == PlayerState.OUCH:
		return

	State = PlayerState.ATTACKING
	lock_move = is_on_floor()

	var vdir = -1 if Input.is_action_pressed("up") else (1 if Input.is_action_pressed("down") else 0)

	if is_on_floor():
		if Input.is_action_pressed("up"):
			start_attack(Attacks.UPGROUND, "upground", Vector2(0,-1), Vector2(visual_dir*10, -60), Vector2(40,120))
			swishsound()
		else:
			start_attack(Attacks.JAB, "jab", Vector2(visual_dir,0), Vector2(visual_dir*40, -30), Vector2(80,50))
			whipsound()
	else:
		if vdir == 1:
			start_attack(Attacks.DAIR, "downair", Vector2(0,1), Vector2(0,0), Vector2(40,70))
			swishsound()
		elif vdir == -1:
			start_attack(Attacks.UAIR, "upair", Vector2(0,-1), Vector2(0,-80), Vector2(50,80))
			whipsound()
		elif dir != visual_dir and dir != 0:
			start_attack(Attacks.BAIR, "backair", Vector2(-visual_dir,0), Vector2(-visual_dir*30, -30), Vector2(80,50))
			swishsound()
		else:
			start_attack(Attacks.FAIR, "forwardair", Vector2(visual_dir,0), Vector2(visual_dir*30, -30), Vector2(80,50))
			swishsound()

			
func start_attack(state, anim, angle, pos, size):
	AttackState = state
	current_attack_anim = anim
	sprite.play(anim)
	spawn_hitbox(5, angle, pos, size, 0.1, 0.5, 1)

func _animation_finished():
	if State == PlayerState.ATTACKING and sprite.animation == current_attack_anim:
		lock_move = false
		State = PlayerState.GENERAL
		AttackState = Attacks.NONE
		current_attack_anim = ""

func _frame_changed():
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

func spawn_hitbox(ticks:int, angle:Vector2, pos:Vector2, size:Vector2, knockback:float, damage:float, power:int):
	var hitbox = load("res://scenes/hitbox.tscn").instantiate()
	hitbox.player = true
	hitbox.size = size
	hitbox.position = pos
	hitbox.ticks = ticks
	hitbox.angle = angle
	hitbox.knockback = knockback
	hitbox.damage = damage
	hitbox.power = power
	hitboxes.add_child(hitbox)

func hit(node: Node):
	if iframes > 1 or State == PlayerState.OUCH: return
	for c in hitboxes.get_children():
		hitboxes.remove_child(c)
		
	global.punchsound()
	global.heat_progress -= 10
	global.witz_health -= 1
	visual_dir = sign(global_position.x - node.get_parent().global_position.x) * -1
	velocity = node.angle * 500
	squeak.pitch_scale = randf_range(.9,1.1)
	squeak.play()
	iframes = 100
	State = PlayerState.OUCH
	AttackState = Attacks.NONE
	stun = 30

func connected_hit(node: Node):
	if node.is_in_group("Enemy"):
		global.heat_progress += 15
	if AttackState == Attacks.DAIR and Input.is_action_pressed("z"):
		velocity.y = JUMP_VELOCITY
		global.heat_progress += 5
		
func apply_state_logic():
	if AttackState != Attacks.NONE and State != PlayerState.OUCH:
		State = PlayerState.ATTACKING

	if State == PlayerState.ATTACKING:
		if is_on_floor() and not AttackState in [Attacks.JAB, Attacks.UPGROUND, Attacks.NONE]:
			AttackState = Attacks.NONE
			State = PlayerState.GENERAL

	if State == PlayerState.OUCH:
		lock_dir = true
		if stun <= 0:
			State = PlayerState.GENERAL
			lock_move = false
			lock_dir = false

	if (not lock_dir) or State == PlayerState.ATTACKING:
		if dir != 0 and last_on_floor < 2:
			visual_dir = int(dir)
			
func update_animation():
	match State:
		PlayerState.GENERAL:
			if is_on_floor():
				var speed = abs(velocity.x)
				if speed > 22:
					if speed > 500:
						sprite.play("run", speed/(WALK_ACCEL + extra_speed))
					else:
						sprite.play("walk", speed/(WALK_ACCEL * 2))

					if ((visual_dir == 1 and velocity.x < 0) or (visual_dir == -1 and velocity.x > 0)) and speed > 22:
						sprite.play("skid")
				else:
					sprite.play("idle")
					if Input.is_action_pressed("down"):
						sprite.play("crouch")
						
			else:
				sprite.play("midair")
				sprite.frame = 0 if velocity.y < 300 else 1
		PlayerState.OUCH:
			sprite.play("ouch")

func random_sfx(a, b):
	if randf() < .5:
		a.pitch_scale = randf_range(.9,1.1)
		a.play()
	else:
		b.pitch_scale = randf_range(.9,1.1)
		b.play()

func jumpsound():
	random_sfx(jump_1, jump_2)

func stepsound():
	random_sfx(step_1, step_2)

func swishsound():
	random_sfx(swish_1, swish_2)

func whipsound():
	random_sfx(whip_1, whip_2)

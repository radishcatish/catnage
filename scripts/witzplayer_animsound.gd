extends AnimatedSprite2D
@onready var main: CharacterBody2D = $".."
@onready var step_1: AudioStreamPlayer2D = $Step1
@onready var step_2: AudioStreamPlayer2D = $Step2
@onready var swish_1: AudioStreamPlayer2D = $Swish1
@onready var swish_2: AudioStreamPlayer2D = $Swish2
@onready var whip_1: AudioStreamPlayer2D = $Whip1
@onready var whip_2: AudioStreamPlayer2D = $Whip2
@onready var whip_3: AudioStreamPlayer2D = $Whip3
@onready var whip_4: AudioStreamPlayer2D = $Whip4
@onready var whop_1: AudioStreamPlayer2D = $Whop1
@onready var whop_2: AudioStreamPlayer2D = $Whop2
@onready var whop_3: AudioStreamPlayer2D = $Whop3
@onready var dir = I.d.x

func _ready() -> void:
	self.frame_changed.connect(_on_frame_changed)
	self.animation_changed.connect(_on_animation_changed)
func _process(_d):
	if main.last_on_floor <= 5:
		dir = I.d.x if I.d.x != 0 else dir
	else:
		dir = sign(main.last_wall_normal) if main.last_on_wall <= 5 else dir
	flip_h = false if dir == 1 else true
	Camera.target = global_position
	if main.last_off_floor == 1:
		stepsound()
	if I.last_z_press <= 5:
		if main.last_on_floor == 7:
			jumpsound()


		if main.last_on_wall == 7:
			jumpsound()
			stepsound()

	match main.state:
		main.PlayerState.GENERAL:
			if main.is_on_floor():
				if ((dir == 1 and main.velocity.x < 0) or (dir == -1 and main.velocity.x > 0)):
					play("skid")
				elif abs(main.velocity.x) > 300:
					play("run", abs(main.velocity.x) / 600)
				elif abs(main.velocity.x) > 10:
					play("walk")
				else:
					play("idle")
			else:
				if main.is_on_wall():
					play("crouch")
				else:
					if main.velocity.y > 0:
						play("midair")
						frame = 1
					else:
						play("midair")
						frame = 0

func _on_frame_changed():
	match animation:
		"walk":
			if frame==1:step_1.play()
			if frame==3:step_2.play()
		"run":
			if frame==1:step_1.play()
			if frame==4:step_2.play()
			
func _on_animation_changed():
	match animation:
		"skid":
			stepsound()
			
	
	
func random_sfx(a, b):
	if randf() < .5:
		a.pitch_scale = randf_range(.9,1.1)
		a.play()
	else:
		b.pitch_scale = randf_range(.9,1.1)
		b.play()
func jumpsound():
	random_sfx(whop_1, whop_2)
func stepsound():
	random_sfx(step_1, step_2)
func swishsound():
	random_sfx(swish_1, swish_2)
func whipsound():
	random_sfx(whip_1, whip_2)

extends CharacterBody2D
class_name overworldplayer
var input_direction: Vector2
@onready var col: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var select_box: Area2D = $Area2D
var is_selecting: bool = false
var side: bool = false
var up: bool = false
var down: bool = false
var pressz: bool = false
var pressx: bool = false
var pressc: bool = false

func _process(_delta: float) -> void:
	input_direction = Input.get_vector(&"arrowleft",&"arrowright",&"arrowup",&"arrowdown")
	if input_direction.x:
		ani.flip_h = input_direction.x < 0
		
	side   = input_direction.x != 0
	up     = input_direction.y < 0
	down   = input_direction.y > 0
	pressz = Input.is_action_pressed(&"jump")
	pressx = Input.is_action_pressed(&"attack")
	pressc = Input.is_action_pressed(&"cbutton")
	
	if up:
		if side:
			ani.play("FS_walk")
		else:
			ani.play("FF_walk")
	elif down:
		if side:
			ani.play("DS_walk")
		else:
			ani.play("DD_walk")
	elif side:
		ani.play("SS_walk")
	else:
		ani.play(ani.animation.substr(0, 2) + &"_idle")
	ani.speed_scale = 1 + float(Input.is_action_pressed(&"jump"))
	
func _physics_process(delta: float) -> void:
	
	if input_direction: 
		select_box.position = Vector2(0, -24) + input_direction.normalized() * 65
		select_box.rotation = input_direction.angle()
	is_selecting = false
	is_selecting = Input.is_action_just_pressed("attack")
	if is_selecting:
		for area in select_box.get_overlapping_areas():
			if area.get_parent() is InteractableObject:
				area.get_parent().interact()
	
	
	velocity = (input_direction * (12000 + float(Input.is_action_pressed(&"jump")) * 12000) ) * delta
	move_and_slide()

extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var glitches: Node = $Glitches
@onready var slaps: Node = $Slaps

var stuntimer: int = 0
@export var direction: int
var visual_direction: int = direction
func _physics_process(_delta: float) -> void:
	stuntimer -= 1 if stuntimer > 0 else 0 
	velocity.y += 40
	velocity.x *= 0.9
	
	
	if stuntimer == 0 and is_on_floor():
		velocity.x -= direction * 10
		animated_sprite_2d.play("walk")
		if is_on_wall():
			velocity.x = 0
			direction = -direction
			position.x += -direction * 2
	else:
		animated_sprite_2d.play("hurt")
	
	move_and_slide()
	animated_sprite_2d.flip_h = false if direction == 1 else true
	
func hit(node:Node):
	stuntimer = 20
	direction = node.angle.x if node.angle.x else direction
	velocity += node.angle * 1000
	var sound1 = glitches.get_child(randi_range(0, glitches.get_child_count() - 1))
	sound1.pitch_scale = randf_range(.9, 1.1)
	sound1.play()
	var sound2 = slaps.get_child(randi_range(0, slaps.get_child_count() - 1))
	sound2.pitch_scale = randf_range(.9, 1.1)
	sound2.play()
	global.punchsound()
	
	

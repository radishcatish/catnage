extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_range: Area2D = $DetectionRange
var start_pos = 1
var target_pos = 1
var dead: bool = false
var deathtimer: int = -1


func _ready() -> void:
	start_pos = global_position
	target_pos = start_pos
	position += Vector2(randf(), randf()) * 42

func _physics_process(_d) -> void:

	
	
	
	
	
	for area in detection_range.get_overlapping_areas():
		if area.get_parent() == global.player:
			var dir = sign(global.player.global_position - global_position).x
			sprite.flip_h = (dir == -1)
			target_pos = global.player.global_position + Vector2(45, 45)
		else:
			target_pos = start_pos
			
			
	var direction_to_target_pos = global_position.direction_to(target_pos)
	#velocity += direction_to_target_pos * 202
	position = target_pos
	move_and_slide()
		


@onready var death_fx: Node = $DeathFX
func hit(_node):
	global.punchsound()
	sprite.play("die")
	var sound3 = death_fx.get_child(randi_range(0, death_fx.get_child_count() - 1))
	sound3.pitch_scale = randf_range(.9, 1.1)
	sound3.play()
	await sprite.animation_finished
	queue_free()
	

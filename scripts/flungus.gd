extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_range: Area2D = $DetectionRange
var start_pos = 1
var target_pos = 1
var waittimer = 400
var dir: int = 0
var dead: bool = false
@onready var hitbox: Area2D = $Hitbox
func _ready() -> void:
	start_pos = global_position
	target_pos = start_pos
	position += Vector2(randf(), randf()) * 42

func _physics_process(_d) -> void:
	if dead: return
	
	if waittimer == 0 or waittimer > 200:
		hitbox.monitoring = false
		target_pos = start_pos
		sprite.play("idle")
		for area in detection_range.get_overlapping_areas():
			if area.get_parent() == global.player:
				dir = sign(global.player.global_position - global_position).x
				sprite.flip_h = (dir == -1)
				target_pos = global.player.global_position + Vector2(200 * -dir, -200)
				waittimer -= 1
		var direction_to_target_pos = global_position.direction_to(target_pos)
		velocity += direction_to_target_pos * 50 - velocity / 20
	else:
		waittimer -= 1
		if waittimer <= 200 and waittimer > 180:
			velocity += Vector2(140 * dir, 100)
			sprite.play("attack")
			hitbox.monitoring = true
			hitbox.angle = velocity.normalized()
			hitbox.knockback = velocity.length() / 3
		else:
			hitbox.monitoring = false
			waittimer = 400
		
	
	move_and_slide()
		

func successful_hit():
	velocity = -velocity
	global.punchsound()

@onready var death_fx: Node = $DeathFX
func hit(_node):
	global.punchsound()
	sprite.play("die")
	dead = true
	var sound3 = death_fx.get_child(randi_range(0, death_fx.get_child_count() - 1))
	sound3.pitch_scale = randf_range(.9, 1.1)
	sound3.play()

	await sprite.animation_finished
	queue_free()
	

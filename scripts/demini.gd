extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var direction: int = 1
var deathtimer: int = -1
var dead: bool = false
@onready var ray_cast_2d: RayCast2D = $AnimatedSprite2D/RayCast2D

func _physics_process(_d):
	if not dead:
		if is_on_wall() or not ray_cast_2d.is_colliding():
			direction = -direction
			position.x += -direction * 2
		velocity.x = direction * 100
	else:
		deathtimer -= 1
		if deathtimer == 0:
			queue_free()
			
	velocity.y += 20
	move_and_slide()
	animated_sprite_2d.scale.x = direction

func hit(node):
	$Hurtbox.queue_free()
	$Hitbox.queue_free()
	global.punchsound()
	velocity = node.angle * node.knockback
	dead = true
	deathtimer = 200
	direction = sign(global_position.x - global.player.global_position.x) * -1
	$CollisionShape2D.set_deferred("disabled", true)
	animated_sprite_2d.play("hurt")
	animated_sprite_2d.z_index = 10

func successful_hit():
	direction = sign(global_position.x - global.player.global_position.x) * -1
	$Bite.pitch_scale = randf_range(.9, 1.1)
	$Bite.play()

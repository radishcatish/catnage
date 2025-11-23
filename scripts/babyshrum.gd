extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var still: bool = true
@export var direction: int = 1
@export var spring_velocity: int = 1500
var animating: bool = false
@onready var ray_cast_2d: RayCast2D = $AnimatedSprite2D/RayCast2D

func _physics_process(_d):
	if not animating:
		if not still:
			if is_on_wall() or not ray_cast_2d.is_colliding():
				direction = -direction
				position.x += -direction * 2
			velocity.x = direction * 100
			animated_sprite_2d.play("walk")
		else:
			animated_sprite_2d.play("idle")
	velocity.y += 20
	move_and_slide()
	animated_sprite_2d.scale.x = direction


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() == global.player and area.name == "Hurtbox":
		global.player.velocity.y = -spring_velocity
		global.player.last_on_floor = 6
		animated_sprite_2d.play("Spring")
		animating = true
		velocity.x = 0
		await animated_sprite_2d.animation_finished
		animating = false

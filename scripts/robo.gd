extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var glitches: Node = $Glitches
@onready var slaps: Node = $Slaps
@onready var detection_range: Area2D = $DetectionRange
@onready var deaths: Node = $Deaths

var health: int = 2
var stuntimer: int = 0
var deathtimer: int = -1
var attacking: bool = false
var spawnhitbox: bool = false
var direction: int = [-1, 1].pick_random()
var visual_direction: int = direction
var dead: bool = false
func _physics_process(_delta: float) -> void:
	if health > 0:
		detection_range.scale.x = direction
		velocity.y += 40
		velocity.x *= 0.9
		stuntimer -= 1 if stuntimer > 0 else 0 
		if stuntimer == 0 and is_on_floor():
			if attacking:
				animated_sprite_2d.play("attack")
				if spawnhitbox:
					global.spawn_hitbox(self, 3, Vector2(-direction, 0.3), Vector2(-direction * 40, -30), Vector2(75,60), .1, .5, 1, false)
					spawnhitbox = false
				await animated_sprite_2d.animation_finished
				attacking = false
			else:
				velocity.x -= direction * 10
				animated_sprite_2d.play("walk")
				if is_on_wall():
					velocity.x = 0
					direction = -direction
					position.x += -direction * 2
		else:
			animated_sprite_2d.play("hurt")
	else:
		$CollisionShape2D.disabled = true
		velocity.y += 30
		animated_sprite_2d.play("hurt")
		deathtimer -= 1

		if deathtimer == 0:
			queue_free()
	
	move_and_slide()
	animated_sprite_2d.flip_h = false if direction == 1 else true
	
func hit(node:Node):
	if dead: return
	direction = sign(global_position.x - node.get_parent().global_position.x) * -1
	attacking = false
	health -= 1
	stuntimer = 20
	var sound1 = glitches.get_child(randi_range(0, glitches.get_child_count() - 1))
	sound1.pitch_scale = randf_range(.9, 1.1)
	sound1.play()
	var sound2 = slaps.get_child(randi_range(0, slaps.get_child_count() - 1))
	sound2.pitch_scale = randf_range(.9, 1.1)
	sound2.play()
	global.punchsound()
	velocity += node.angle * 1000
	if health <= 0:
		deathtimer = 500
		dead = true
		var sound3 = deaths.get_child(randi_range(0, deaths.get_child_count() - 1))
		sound3.pitch_scale = randf_range(.9, 1.1)
		sound3.play()

func _on_detection_range_area_entered(area: Area2D) -> void:
	if area.owner == global.player and not attacking:
		attacking = true
		spawnhitbox = true
		

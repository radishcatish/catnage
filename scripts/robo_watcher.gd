extends CharacterBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slaps: Node = $Slaps
@onready var glitches: Node = $Glitches
@onready var detection_range: Area2D = $DetectionRange
@onready var start_pos = global_position
var stun: int = 0
var iframes: int = 0
var tmr: float = 0
func _process(_d) -> void:
	if Engine.get_frames_drawn() % 2 == 0 and iframes > 1:
		sprite.visible = !sprite.visible
	else:
		sprite.visible = true


func _physics_process(d) -> void:
	iframes = max(iframes - 1, 0)
	stun = max(stun - 1, 0)
	if stun == 0:
		global_position.x = move_toward(global_position.x, start_pos.x, d * 150)
		global_position.y = move_toward(global_position.y, start_pos.y, d * 150)
		sprite.play("default")
		tmr += .1
		sprite.position.y = sin(tmr) * 10
		
		for area in detection_range.get_overlapping_areas():
			if area.get_parent() == global.player:
				var dir = sign(global.player.global_position - global_position).x
				sprite.flip_h = (dir == -1)
		
		
	else:
		sprite.play("hurt")
		sprite.position.y = 0
		velocity.y += 20
		velocity.x *= .95
		move_and_slide()
	


func hit(node: Node):
	if stun == 0 and iframes == 0:
		stun = 20
		iframes = 30
		velocity = node.angle * 500
		var sound1 = glitches.get_child(randi_range(0, glitches.get_child_count() - 1))
		sound1.pitch_scale = randf_range(.9, 1.1)
		sound1.play()
		var sound2 = slaps.get_child(randi_range(0, slaps.get_child_count() - 1))
		sound2.pitch_scale = randf_range(.9, 1.1)
		sound2.play()
		global.punchsound()

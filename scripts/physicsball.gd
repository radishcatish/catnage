extends CharacterBody2D
class_name physicsball
var retainedVelocity := Vector2(0.0, 0.0)
@onready var anim = $AnimatedSprite2D
var prev_dis := 0.0
@onready var player = get_tree().get_first_node_in_group("player")
var dontCollide := false
func _physics_process(_delta):
	
	var curr_dis = global_position.distance_to(player.global_position)
	if curr_dis > prev_dis:
		dontCollide = true
	else:
		dontCollide = false
	prev_dis = curr_dis
	
	if round((velocity.length_squared() / 1000) * 0.05) > 0.2:
		anim.play("rolling")
	elif is_on_floor():
		anim.play("idle")

	self.velocity.y += 21

	for body in $Area2D.get_overlapping_bodies():
		if body is witzPlayer:
			if body.velocity.length() >= self.velocity.length() and !dontCollide:
				self.velocity.x = body.velocity.x * 1.2
				self.velocity.y = body.velocity.y * 1.5

	self.retainedVelocity = self.velocity
	if self.move_and_slide():
		self.velocity = retainedVelocity.bounce(get_last_slide_collision().get_normal()) * 0.85
		

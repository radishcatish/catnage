extends CharacterBody2D
class_name kitting
@onready var anim = $vis
var just_now_is_on_floor: bool = false
var last_is_on_floor: bool = false
var state:String = "spawn"
var plrdirection = 0
var enemyhit = 0
var aerialMovesLeft = 3
var health = 4
var stunned = false
var invincible = false
var walljumpDir = 0
var canWalljump = false
var transparency = 1
func defineshit():
	#Misc

	if just_now_is_on_floor == true:
		$land.play()
		aerialMovesLeft = 3
	if $vis.animation == "walk" and $vis.get_frame() == 1 and not $stip.is_playing():
		$stip.play()
	if $vis.animation == "walk" and $vis.get_frame() == 3 and not $step.is_playing():
		$step.play()
	if state == "idle":
		anim.play("idle")
		enemyhit = 0
	if state == "moving": 
		anim.play("walk")
		enemyhit = 0
	#Left and right
	if Input.is_action_pressed("arrowright"):
		plrdirection = 1
		walljumpDir = -1
		$attackbox.position = Vector2(14, 0)
		$vis.flip_h = false
	if Input.is_action_pressed("arrowleft"):
		plrdirection = -1
		walljumpDir = 1
		$attackbox.position = Vector2(-14, 0)
		$vis.flip_h = true
	#Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -500
		$jump.play()
	if not is_on_floor() and not state == "jump" and Input.is_action_just_pressed("jump") and aerialMovesLeft >= 0:
		velocity.y = -300
		aerialMovesLeft = aerialMovesLeft - 1
		state = "jump"
		$jump.play()
	if is_on_floor() and abs(velocity.x) <= 80 and not $vis.animation == "atk":
			state = "idle"
func otherstuff():
	if Input.is_action_pressed("arrowright") or Input.is_action_pressed("arrowleft"):
		velocity.x = velocity.x + 30 * plrdirection
		if abs(velocity.x) >= 270  : anim.set_speed_scale(abs(velocity.x) / 12)
		if is_on_floor() and not $vis.animation == "atk":
			state = "moving" 
	if not is_on_floor() and velocity.y < 0 and not state == "atkair":
		state = "jump"
		enemyhit = 0
		anim.play("jump")
	if not is_on_floor() and velocity.y > 0 and not state == "atkair":
		state = "fall"
		enemyhit = 0
		anim.play("fall")
	if not is_on_floor() and Input.is_action_just_pressed("arrowdown"):
		velocity.y = 400
	if is_on_wall() and Input.is_action_just_pressed("arrowleft"):
		print("yea")
func attack():
	if Input.is_action_just_pressed("attack"):
		if is_on_floor()  :
			enemyhit = 1
			$atk.play()
			state = "attack"
			anim.play("atk")
			velocity.x = velocity.x / 3
		elif aerialMovesLeft >= 0   :
			state = "atkair"
			anim.play("atkair")
			$atk.play()
			aerialMovesLeft = aerialMovesLeft - 1
			velocity.y = -50
			velocity.x = 500 * plrdirection
			enemyhit = 1
			if state == "atkair":
				if Input.is_action_just_pressed("jump") and aerialMovesLeft >= 0:
					state = "jump"
					velocity.y = -300
					aerialMovesLeft = aerialMovesLeft - 1
					$jump.play()
				if abs(velocity.x) >= 340: enemyhit = 1
				if is_on_floor(): state = "moving"

	if $vis.get_frame() == 4 and $vis.animation == "atk":
		state = "moving"
		anim.play("walk")
	if enemyhit == 1: $attackbox.monitoring = true
	if enemyhit == 0: $attackbox.monitoring = false


func _physics_process(delta):
	if state == "spawn" and $vis.get_frame() == 8:
		state = "idle"
		anim.play("idle")
	elif state == "spawn":
		anim.set_speed_scale(15)
		anim.play("spawn")
	anim.set_speed_scale(15)
	velocity.x = velocity.x * 0.9
	if not $vis.animation == "spawn":
		#hitkitting()
		if stunned == false and not state == "dead":	
			attack()
			defineshit()
			otherstuff()
			#hitenemy()
	velocity.y += 1000 * delta
	self.set_velocity(velocity)
	self.set_up_direction(Vector2.UP)
	self.move_and_slide()
	velocity = self.velocity
	if (abs(velocity.y)) < 0.9: velocity.y = 0
	if (abs(velocity.x)) < 25: velocity.x = 0

	if is_on_floor() and last_is_on_floor == false:
		last_is_on_floor = is_on_floor()
		just_now_is_on_floor = true
	else:
		just_now_is_on_floor = false
		last_is_on_floor = is_on_floor()
	#print("State:")
	#print(state)
	#print("Velocity (x, y):")
	#print(velocity)
	#print("Aerial moves left (-1 to 3):")
	#print(aerialMovesLeft)
	#print("Can hit an enemy?")
	#print(enemyhit)
	#print("Health:")
	#print(health)
	

#Stuff regarding player and enemies interacting w/ eachother
#func hitenemy():
	#if enemyhit == 1:
		#for area in $attackbox.get_overlapping_areas():
			#if area.get_parent() is enemy:
				#area.get_parent().death = 1
				#area.get_parent().endirection = plrdirection
	#elif enemyhit == 0: pass
#func hitkitting():
	#var transparency = 100
	#if not state == "dead":
		#for area in $hitbox.get_overlapping_areas():
			#if area.get_parent() is enemy: 
				#if area.get_parent().death == 0:
					#if invincible == false:
						#$hitsuccessful.play()
						#health = health - 1
						#transparency = 0.60
						#invincible = true
						#$timerinv.start()
						#stunned = true
						#$timerstun.start()
						#position = Vector2(position.x, position.y - 12)
						#velocity.x = -400 * plrdirection 
						#velocity.y = -400
	
	if stunned == true: anim.play("gothit")
	if invincible == true: transparency = 0.60
	if health < 4 and $timerheal.time_left == 0:
		$timerheal.start()

	if health == 4:
		$vis.position = Vector2(0, -16)
		$vis.self_modulate = Color(1,1,1,transparency)
		$vis/sweat.emitting = false
	if health == 3:
		$vis.position = Vector2(0, -16)
		$vis/sweat.emitting = true
		$vis/sweat.amount_ratio = 0.5
		$vis/sweat.amount = 1
		$vis.self_modulate = Color(1,0.90,0.90,transparency)
	if health == 2:
		$vis.position = Vector2(0, -16)
		$vis/sweat.emitting = true
		$vis/sweat.amount_ratio = 1
		$vis/sweat.amount = 3
		$vis.self_modulate = Color(1,0.75,0.75,transparency)
	if health == 1:
		$vis.position = Vector2(randi_range(-1,1), -16)
		$vis/sweat.emitting = true
		$vis/sweat.amount = 6
		$vis.self_modulate = Color(1,0.60,0.60,transparency)
	if health == 0:
		$vis.position = Vector2(0, -16)
		$vis/sweat.emitting = false
		$vis.self_modulate = Color(1,1,1,transparency)
		velocity.y = 300
		state = "dead"
		anim.play("dead")
	if state == "dead":
		anim.play("dead")
		health = 0 
		velocity.x = 0

func _on_timerinv_timeout():

	
	transparency = 1
	invincible = false
func _on_timerstun_timeout(): stunned = false
func _on_timerheal_timeout():
	if not health > 4 or health == 0: #just a precaution
		health = health + 1

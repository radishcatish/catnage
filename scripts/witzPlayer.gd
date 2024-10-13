extends CharacterBody2D
class_name witzPlayer
# Started work on state machine and new player code 2/29/2024, at 10:15 PM. Wish me luck.
@export var plrDir := 1
@export var titleText := "level"
@export var levelDesc := "..."
@export var health := 8
@export var cameraon := true
enum plrStates {spawn, none, idle, walk, jump, fall, atkcombo, wallslide, walljump, stomp}
var state := plrStates.spawn
var lockInput := false
var footstep := 0
var inputDir := 0.0
var just_now_is_on_floor := false
var last_is_on_floor := false
var just_now_not_on_wall_only := false
var last_not_on_wall_only := false
var just_now_not_on_floor := false
var last_not_on_floor := false
var isAttacking := false
var aerialMovesLeft: = 4
var noJumpState := ["gothit"]
var noJumpAnim := ["gothit", "kickoffwall", "atkair", "stomp"]
var attackAnims := ["atkair", "combo1", "combo2"]
var lastWalljumpDir := 0
var kickPower := Vector2(0.0, 0.0)



# hackerman
@export var noclip = false
# No touching!!! This halts ALL code execution! Put this before every function!
var lock = false

func _ready():
	$camera.enabled = cameraon
	$PlayerUi/UI/levelstart/TitleText.text = titleText
	$PlayerUi/UI/levelstart/LevelDesc.text = levelDesc
func _process(_float) -> void:
	if !lock:
		$PlayerUi/UI/statetext.text = "state: " + plrStates.find_key(state) + "\nposition: " + str(floor(global_position)) + "\nanimation: "+ $vis.animation + "\nvelocity: " + str(floor(velocity)) + "\ndirection: "+ str(plrDir) + "\nhealth: "+ str(health) + "\njumpqueue: " + str($tmr/timerjumpqueue.time_left) + "\nattacking: " + str(isAttacking)
		if state == plrStates.idle: $vis.play("idle")
		if state == plrStates.walk: $vis.play("walk")
		if state == plrStates.jump and not noJumpAnim.has($vis.animation): $vis.play("jump")
		if state == plrStates.fall and not noJumpAnim.has($vis.animation): $vis.play("fall")
		if state == plrStates.stomp: $vis.play("stomp")
		$vis.scale = Vector2(plrDir, 1)
		if $vis.animation == "walk":
			footstepsfx($vis.get_frame())
		if state == plrStates.wallslide: $vis.play("onwall")
		if state == plrStates.walljump: $vis.play("kickoffwall") 
		if state == plrStates.walk: $vis.set_speed_scale(abs(velocity.x) / 40)
		else: $vis.set_speed_scale(10)
	$camera.offset.x = lerp($camera.offset.x, get_real_velocity().x / 8, 0.03)
	$camera.offset.y = lerp($camera.offset.y, get_real_velocity().y / 16, 0.08)
	if $vis.scale.y != 1: $vis.scale.y = move_toward($vis.scale.y, 1, 0.05)
	if Input.is_action_just_pressed("debug"):
		$PlayerUi/UI/WHITTING.scale = Vector2(1.1,1.1)
		get_tree().create_tween().tween_property($PlayerUi/UI/WHITTING, "scale", Vector2(1,1), 0.3).set_ease(Tween.EASE_OUT)

func footstepsfx(frame):

	if frame == 3 and not $snd/stip.is_playing():
		$snd/stip.play()
	if frame == 1 and not $snd/step.is_playing():
		$snd/step.play()
	if frame == 2 or frame == 4:
		$snd/step.stop()
		$snd/stip.stop()

var tempgimmickstate = 0
func _physics_process(_delta):
	

	if !lock:
		
		input()
		misc()
		midair()
		walljump()
		ouchie()
	
		# This is awful and I have no clue how to make it not awful
		if is_on_floor() and last_is_on_floor == false:
			last_is_on_floor = is_on_floor()
			just_now_is_on_floor = true
		else:
			just_now_is_on_floor = false
			last_is_on_floor = is_on_floor()
			
		if not is_on_floor() and last_not_on_floor == true:
			last_not_on_floor = is_on_floor()
			just_now_not_on_floor = true
		else:
			just_now_not_on_floor = false
			last_not_on_floor = is_on_floor()

		if not is_on_wall_only() and last_not_on_wall_only == true:
			last_not_on_wall_only = is_on_wall_only()
			just_now_not_on_wall_only = true
		else:
			just_now_not_on_wall_only = false
			last_not_on_wall_only = is_on_wall_only()
	
		tempgimmickstate = 0
		for area in $hitbox.get_overlapping_areas():
			if area is space:
				tempgimmickstate = 1
	
		if tempgimmickstate == 0:
			velocity.x = (velocity.x * 0.85)
			velocity.y += 40
		else:
			velocity.x = (velocity.x * 0.95)
			velocity.y += 7
		move_and_slide()
			# thanks kidscancode
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_force(-c.get_normal())
func misc(): # Things that need to run all the time
	if !lock:
		if just_now_is_on_floor: 
			$snd/land.play()
			aerialMovesLeft = 4
			lastWalljumpDir = 0
		if just_now_not_on_floor and not Input.is_action_pressed("jump"):
			$tmr/timercoyotetime.stop()
			$tmr/timercoyotetime.start()
		if lastWalljumpDir != 0: 
			plrDir = -lastWalljumpDir
		if state in [plrStates.atkcombo, plrStates.stomp]: 
			if $vis.animation == "atkair" and $vis.get_frame() == 4:
				state = plrStates.fall
				$vis.animation = "fall"
			if state == plrStates.stomp:
				isAttacking = true
			for area in $attackbox.get_overlapping_areas():
				#if area.get_parent() is enemy:
					#area.get_parent().death = 1
				if area.get_parent() is physicsball:
					area.get_parent().velocity = kickPower
	
		else: isAttacking = false
		
		if velocity.y > 1500 and state in [plrStates.jump, plrStates.fall]:
			state = plrStates.stomp
			isAttacking = true
			$attackbox/atkshape.position = Vector2(0, 40)
			$attackbox/atkshape.scale = Vector2(10, 15)
			


			
		if state != plrStates.atkcombo:
			if is_on_floor() and abs(velocity.x) < 100:
				state = plrStates.idle
			if is_on_floor() and abs(velocity.x) > 100:
				state = plrStates.walk

func input(): # The thing that takes input. Some movement code being in here is just because a function to hold 3 lines of code is stupid.
	if !lock or !lockInput:
		inputDir = Input.get_axis("arrowleft", "arrowright")
		@warning_ignore("narrowing_conversion")
		if inputDir != 0: plrDir = inputDir
		velocity.x = velocity.x + (105 + (tempgimmickstate * 60)) * inputDir
				
		if Input.is_action_just_pressed("attack"): attackhandler()
		if Input.is_action_just_pressed("arrowdown"): stomp()
		if Input.is_action_just_pressed("jump") or (not $tmr/timerjumpqueue.is_stopped() and is_on_floor()): jump()
		
func midair():
	if !lock:
		if not (is_on_floor() or is_on_wall_only() or isAttacking == true):
			if velocity.y < 0: 
				state = plrStates.jump 
			if velocity.y > 0: 
				state = plrStates.fall
		if lastWalljumpDir == 1: plrDir = 1
		elif lastWalljumpDir == -1: plrDir = -1
		if not Input.is_action_pressed("jump") and not $tmr/timerjumpheight.is_stopped(): 
			$tmr/timerjumpheight.stop()
			velocity.y /= 3

func jump():
	if !lock:
		$tmr/timerjumpqueue.stop()
		if is_on_floor() or not $tmr/timercoyotetime.is_stopped() and state == plrStates.fall:
			$vis.scale.y = 1.5
			velocity.y = -1250
			$snd/jump.play()
			$tmr/timerjumpheight.start()
			$tmr/timercoyotetime.stop()
		if not is_on_floor() and not state == plrStates.wallslide: $tmr/timerjumpqueue.start()

func walljump():
	if !lock:
		if just_now_not_on_wall_only:
			
			$tmr/timerwallcoyotetime.stop()
			$tmr/timerwallcoyotetime.start()
		if is_on_wall_only() and (get_wall_normal().x > 0 and not lastWalljumpDir == 1 or get_wall_normal().x < 0 and not lastWalljumpDir == -1) and (Input.is_action_pressed("arrowleft") or Input.is_action_pressed("arrowright")):
			velocity.y *= 0.89
			state = plrStates.wallslide
			
		if not $tmr/timerwallcoyotetime.is_stopped() or state == plrStates.wallslide:
			if Input.is_action_just_pressed("jump") or not $tmr/timerjumpqueue.is_stopped():
				if get_wall_normal().x > 0 and not lastWalljumpDir == 1:
					lastWalljumpDir = 1
					velocity = Vector2(900, -1100)
					$snd/jumpoffwall.play()
					state = plrStates.walljump
					$tmr/timerjumpqueue.stop()
				if get_wall_normal().x < 0 and not lastWalljumpDir == -1:
					lastWalljumpDir = -1
					velocity = Vector2(-900, -1100)
					$snd/jumpoffwall.play()
					state = plrStates.walljump
					$tmr/timerjumpqueue.stop()
					
		if Input.is_action_just_pressed("attack") and state == plrStates.wallslide:
			if get_wall_normal().x > 0 and not lastWalljumpDir == 1:
				lastWalljumpDir = 1
				neutralattackair()
				velocity = Vector2(1800, -400)
				$snd/jumpoffwall.play()
			if get_wall_normal().x < 0 and not lastWalljumpDir == -1:
				lastWalljumpDir = -1
				neutralattackair()
				velocity = Vector2(-1800, -400)
				$snd/jumpoffwall.play()

func attackhandler(): # Thing that does checks to see which kind of attack needs to happen
	if !lock:
		if not (Input.is_action_pressed("jump") or Input.is_action_pressed("arrowdown") or Input.is_action_pressed("arrowup")):
			if not state == plrStates.atkcombo: neutralattackair()
	

func neutralattackair(): # Attacking in the air while holding left, right, or nothing.
	if !lock:
		$snd/atk.play()
		isAttacking = true
		state = plrStates.atkcombo
		$vis.play("atkair")
		$attackbox/atkshape.position = Vector2((21 * plrDir), -23)
		$attackbox/atkshape.scale = Vector2(10, 19)
		kickPower = velocity + Vector2(800 * plrDir, -800) 
		velocity.x *= 1.6
		velocity.y /= 2

func stomp():
	if not is_on_floor() and not (state == plrStates.stomp):
		$snd/atk.play()
		$tmr/timerjumpheight.stop()
		velocity.y = 1550
		kickPower = Vector2(0, velocity.y * 1.5)


func ouchie(): # Code for Witz being damaged
	
	if !lock && !noclip:
		if health <= 0:
			lock = true
			state = plrStates.none
			$vis.animation = "gothit"
			await get_tree().create_timer(3).timeout
			get_tree().reload_current_scene()
			
		if $tmr/timerinv.is_stopped():
			for area in $hitbox.get_overlapping_areas():
				if area is hurtbox:
					$snd/hitsuccessful.play()
					health -= area.damage
					velocity = Vector2(800 * -plrDir, -500)
					$vis.animation = "gothit"
					$tmr/timerinv.start()
					state = plrStates.none
					lock = true
					await get_tree().create_timer(0.3).timeout
					lock = false
					await get_tree().create_timer(0.1).timeout
					$vis.animation = "fall"
		 ## This codes make Witz die. RIP in peperonis Witz

extends Node
@warning_ignore_start("integer_division")
@onready var player = get_tree().get_first_node_in_group("Player")
var heat_progress: int = 0
var heat_progress_before: int = 0
var heat_progress_wait : int = 0
var witz_health: int = 8

func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(_delta: float) -> void:
	
	var negative_heat = (-heat_progress + 1100) / 100
	heat_progress_wait -= 1 if heat_progress_wait > 0 else 0
	
	heat_progress = clamp(heat_progress, 0, 1100)
	if heat_progress > heat_progress_before:
		heat_progress_wait += 50
	heat_progress_before = heat_progress
		
	if heat_progress_wait <= 0 and abs(heat_progress_wait) % (1 + negative_heat / 3) == 0:
		heat_progress -= 1


func punchsound():
	var s = $Sounds/Punch.get_child(randi_range(0, $Sounds/Punch.get_child_count() - 1))
	s.pitch_scale = randf_range(.9, 1.1)
	s.play()

func spawn_hitbox(node: Node, ticks:int,angle:Vector2,pos:Vector2,size:Vector2,knockback:float,damage:float,power:int, plr:bool):
	var hitbox = load("res://scenes/hitbox.tscn").duplicate().instantiate()
	hitbox.player = plr
	hitbox.size = size
	hitbox.position = pos
	hitbox.ticks = ticks
	hitbox.angle = angle
	hitbox.knockback = knockback
	hitbox.damage = damage
	hitbox.power = power
	node.add_child(hitbox)

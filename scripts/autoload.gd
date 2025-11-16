extends Node
@onready var player = get_tree().get_first_node_in_group("Player")
var heat_progress: int = 0
var heat_progress_before: int = 0
var heat_progress_wait : int = 0
func _physics_process(_delta: float) -> void:
	var negative_heat = (-heat_progress + 1100) / 100
	heat_progress_wait -= 1
	
	heat_progress = clamp(heat_progress, 0, 1100)
	if heat_progress > heat_progress_before:
		heat_progress_wait = 50 + (heat_progress / 100) * 20
	heat_progress_before = heat_progress
		
	if heat_progress_wait < 0 and abs(heat_progress_wait) % (1 + negative_heat / 3) == 0:
		heat_progress -= 1

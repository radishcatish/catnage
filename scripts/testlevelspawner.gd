extends Node

var timer:int=0
var timer2:int=0
func _physics_process(_delta: float) -> void:
	timer += 1
	
	if timer % (200 - timer2) == 1:
		timer2 += 1
		var child = load("res://scenes/robo.tscn").duplicate().instantiate()
		child.position.x = randf_range(-640, 640)
		add_child(child)

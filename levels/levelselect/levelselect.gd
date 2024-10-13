extends Node2D
# Hiya, this handles the level select! it's mostly just buttons, haha.
# Also, if you're not a beta tester, stop snooping! >:|



# Control
@onready var buttonpress = $AudioStreamPlayer
@onready var buttondecline = $AudioStreamPlayer2

func tl1_pressed(): 
	buttonpress.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://levels/testparkour/level.tscn")

func ocl_pressed(): 
	buttonpress.play()
	$AudioStreamPlayer3.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://levels/oldcatnagelevelcomp/oldcatnagelevelcomp.tscn")

func _on_tl_2_pressed():
	buttondecline.play()

func _on_bt_pressed():
	buttonpress.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://levels/testball/testball.tscn")
	
func _on_pb_2_pressed():
	buttonpress.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://levels/testball2/testball2.tscn")
	
	
# Node2d
var center := Vector2(576, 350)
var centerAbove = center + Vector2(0, -700)
func _process(_delta): 
	$Camera2D.global_position = ($witzPlayer.global_position + Vector2(576,120)) * 0.5

	if $witzPlayer.global_position.x < -546:
		$witzPlayer.global_position.x = -545
	if $witzPlayer.global_position.x > 1701:
		$witzPlayer.global_position.x = 1700
	if $witzPlayer.global_position.y > 672:
		$witzPlayer.global_position = center 
		$witzPlayer.velocity = Vector2(0,0)
	
	
	
	if $physicsball.global_position.y > 672:
		$physicsball.global_position = centerAbove
		$physicsball.velocity = Vector2(-100,0)
		
	if $physicsball2.global_position.y > 672:
		$physicsball2.global_position = centerAbove
		$physicsball2.velocity = Vector2(100,0)

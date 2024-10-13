extends Node2D
func _process(delta): 
	$Polygon2D.polygon = $StaticBody2D/CollisionPolygon2D.polygon
	
	var distv1 = $physicsball.global_position.distance_to($witzPlayer.global_position) / 500
	var distv2 = Vector2(clamp(1 / distv1, .32, .64), clamp( 1 / distv1, .32, .64)) 
	$Camera2D.global_position = ($witzPlayer.global_position + $physicsball.global_position) * 0.5
	
	$Camera2D.zoom = distv2

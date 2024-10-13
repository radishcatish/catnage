extends Node2D
class_name InteractableObject
var is_on: bool = false



func interact():
	is_on = !is_on

	if is_on:
		onfunc()
	else:
		offfunc()
		

func onfunc():
	$Jumpoffwall.play()
	$PointLight2D.visible = true
	$Apogustester.scale.y = 1
func offfunc():
	$PointLight2D.visible = false
	$Land.play()
	$Apogustester.scale.y = .5

extends CanvasLayer
@export var titletext = "Title Text"
@export var leveldesc = "Level Description"
func _ready():
	$UI/levelstart/TitleText.text = titletext
	$UI/levelstart/LevelDesc.text = leveldesc
	var tween = get_tree().create_tween()
	tween.tween_property($UI/Black, "position", Vector2(2000, -2000), 3).set_trans(Tween.TRANS_SINE)
	var tween2 = get_tree().create_tween()
	tween2.tween_property($UI/levelstart, "position", Vector2(-240, 400), 2).set_trans(Tween.TRANS_SINE)
	
func _on_timer_timeout():
	var tween3 = get_tree().create_tween()
	tween3.tween_property($UI/levelstart, "position", Vector2(2000, 400), 2).set_trans(Tween.TRANS_SINE)
func _process(_delta):
	pass


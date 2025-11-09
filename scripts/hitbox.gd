extends Area2D
var ticks:     int     = 1
var angle:     Vector2 = Vector2.ZERO
var knockback: float   = 1
var damage:    float   = .5
var power:     int     = 1
var player:    bool    = false
var size:      Vector2 = Vector2.ZERO
@onready var collision: CollisionShape2D = $CollisionShape2D

var hit_hurtboxes: Array = []
func _on_area_entered(area: Area2D) -> void:
	if area not in hit_hurtboxes:
		hit_hurtboxes.append(area)

func _physics_process(_delta) -> void:
	collision.shape.size = size
	ticks -= 1
	if ticks <= 0:
		queue_free()

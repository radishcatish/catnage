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
	if player:
		if area not in hit_hurtboxes:
			if area.owner and area.owner.has_method("hit"):
				
				area.owner.hit(self)
				hit_hurtboxes.append(area)
				global.heat_progress += 15
	else:
		if area.owner.name == "Witz":
			area.owner.hit()
			queue_free()

func _physics_process(_delta) -> void:
	collision.shape.size = size
	ticks -= 1
	if ticks <= 0:
		queue_free()


func hit():
	print("hitbox hit other hitbox (bad)")

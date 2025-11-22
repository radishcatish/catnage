extends Area2D
var ticks:     int     = 1
var angle:     Vector2 = Vector2.ZERO
var knockback: float   = 1
var damage:    float   = 1
var power:     int     = 1
var player:    bool    = false
var size:      Vector2 = Vector2.ZERO
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision.shape.size = size

var hit_hurtboxes: Array = []
func _on_area_entered(area: Area2D) -> void:
	if player:
		if area not in hit_hurtboxes and not area.get_parent() == global.player:
			if area and area.name == "Hurtbox":
				var parent = area.get_parent()
				if parent and parent.has_method("hit"):
					global.player.connected_hit(parent)
					parent.hit(self)
					hit_hurtboxes.append(area)
	else:
		if area.get_parent() == global.player:
			global.player.hit(self)
			queue_free()

func _physics_process(_delta) -> void:
	ticks -= 1
	if ticks <= 0:
		queue_free()

extends CharacterBody2D
class_name Actor
var health: int = 1
signal hurt(damage)

func apply_damage(damage: int) -> void:
	emit_signal("hurt", damage)

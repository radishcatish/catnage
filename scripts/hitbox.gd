extends Area2D
var ticks:     int     = 1
var angle:     Vector2 = Vector2.ZERO
var knockback: float   = 1
var damage:    float   = .5
var power:     int     = 1
var player:    bool    = false
var size:      Vector2 = Vector2.ZERO
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision.shape.size = size

var hit_hurtboxes: Array = []
func _on_area_entered(area: Area2D) -> void:
	if player:
		var witz: CharacterBody2D = $"../.."
		if area not in hit_hurtboxes and not area.get_parent() == global.player:
			if area.get_parent() and area.owner.has_method("hit") and area.name == "Hurtbox":
				witz.connected_hit(area.get_parent())
				area.get_parent().hit(self)
				hit_hurtboxes.append(area)
	else:
		if area.get_parent() == global.player:
			global.player.hit(self)
			queue_free()

func _physics_process(_delta) -> void:
	ticks -= 1
	if ticks <= 0:
		queue_free()

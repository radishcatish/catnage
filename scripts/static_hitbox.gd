extends Area2D
@export var angle:     Vector2 = Vector2.ZERO
@export var knockback: float   = 0
@export var damage:    float   = 1
@onready var parent = get_parent()

func _physics_process(_d):
	for area in get_overlapping_areas():
		if area.get_parent() == global.player and area.name == "Hurtbox" and not global.player.iframes > 1:
			global.player.hit(self)
			if parent.has_method("successful_hit"):
				parent.successful_hit()

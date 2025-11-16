extends Node2D
@onready var autoload: Node = $"../.."
@onready var heat_meter: TextureProgressBar = $HeatMeter
@onready var health_bar: AnimatedSprite2D = $HealthBar
@onready var mult: AnimatedSprite2D = $Mult
var colors = PackedColorArray([
	Color.from_hsv(0, 0, .5), 
	Color.from_hsv(0, .5, .5), 
	Color.from_hsv(1, 1, 1),
	Color.from_hsv(0.1, 1, 1),
	Color.from_hsv(0.15, 1, 1),
	Color.from_hsv(0.25, 1, 0.7),
	Color.from_hsv(0.45, 1, 1),
	Color.from_hsv(0.55, 1, 1),
	Color.from_hsv(0.7, 1, 1),
	Color.from_hsv(0.9, 1, 1),
	Color.from_hsv(1, .2, 1),
	Color.from_hsv(1, .5, 1),
	Color.from_hsv(1, .9, 1)
	])


func _process(delta: float) -> void:
	heat_meter.value = autoload.heat_progress % 100
	mult.frame = autoload.heat_progress / 100
	health_bar.frame = autoload.player.health
	var heat_meter_color = snapped((autoload.heat_progress / 100.0 ), 0) 
	heat_meter.tint_under = colors[heat_meter_color]
	print(heat_meter_color)
	if autoload.heat_progress == 1200:
		heat_meter.tint_progress = colors[12]
	else:
		heat_meter.tint_progress = colors[heat_meter_color + 1]
	
	

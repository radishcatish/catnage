extends Node2D
@onready var autoload: Node = $"../.."
@onready var heat_meter: TextureProgressBar = $HeatMeter
@onready var detail: Sprite2D = $HeatMeter/detail
@onready var portrait_bounds: Polygon2D = $PortraitBounds
@onready var portrait: AnimatedSprite2D = $PortraitBounds/Portrait
@onready var health_bar: AnimatedSprite2D = $HealthBar
@onready var mult: AnimatedSprite2D = $Mult
@onready var score: RichTextLabel = $Score

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

var heat_display := 0.0
func _process(delta: float) -> void:
	heat_display = lerp(heat_display, float(autoload.heat_progress), delta * 3.5)
	heat_meter.value = int(heat_display) % 100
	mult.frame = heat_display / 100
	health_bar.frame = autoload.witz_health
	scale = Vector2(2,2) if DisplayServer.window_get_size() >= Vector2i(1500,750) else Vector2(1,1)
	score.text = str(autoload.score)
	var heat_meter_color = snapped((heat_display / 100.0 ), 0) 
	heat_meter.tint_under = colors[heat_meter_color]
	if autoload.heat_progress == 1200:
		heat_meter.tint_progress = colors[12]
	else:
		heat_meter.tint_progress = colors[heat_meter_color + 1]
	
	

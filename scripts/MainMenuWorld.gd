extends Marker2D

@export var area: Control

var _noise := FastNoiseLite.new()
var _noise_time := 0.0

func _process(delta: float) -> void:
	var size = floor(area.size.y / 300)
	scale = Vector2(size, size)
	_noise_time += delta * 300
	position.x = _noise.get_noise_2d(_noise_time, 0.0) * scale.x
	position.y = _noise.get_noise_2d(_noise_time, 500.0) * scale.y

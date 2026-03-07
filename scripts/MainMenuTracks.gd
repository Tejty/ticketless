extends TileMapLayer

func _process(delta: float) -> void:
	position.y -= 1000 * delta
	if position.y < -600:
		position.y = 600

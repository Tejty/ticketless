class_name InputComponent extends Node

var direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")

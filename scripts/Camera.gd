extends Camera2D

@export var target: Node2D
@export var speed: float = 1

func _ready() -> void:
	position = target.position

func _process(delta: float) -> void:
	position = position + (target.position - position) * delta * speed

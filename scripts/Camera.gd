extends Camera2D

@export var target: Node2D
@export var speed: float = 1

var _prev_parent: Node
var _prev_parent_pos: Vector2

func _ready() -> void:
	_prev_parent = target.get_parent()
	_prev_parent_pos = _prev_parent.global_position
	position = target.global_position

func _process(delta: float) -> void:
	var parent := target.get_parent()
	if parent != _prev_parent:
		# Player changed parent (boarded/deboarded) — reset so no position jump.
		_prev_parent = parent
		_prev_parent_pos = parent.global_position

	# Instantly apply the parent's (train's) movement so the camera rides with it.
	var parent_pos: Vector2 = parent.global_position
	position += parent_pos - _prev_parent_pos
	_prev_parent_pos = parent_pos

	# Smoothly lerp for the player's own input-driven movement.
	position += (target.global_position - position) * delta * speed

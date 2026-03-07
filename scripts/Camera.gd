extends Camera2D

@export var target: Node2D
@export var speed: float = 1
@export var offset_up: float = 100.0

var _prev_parent: Node
var _prev_parent_pos: Vector2

var _noise := FastNoiseLite.new()
var _noise_time := 0.0

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
	var parent_velocity := parent_pos - _prev_parent_pos
	_prev_parent_pos = parent_pos
	position += parent_velocity
	
	# Add wobble based on parent speed
	var parent_speed := parent_velocity.length_squared()
	_noise_time += 500 * delta
	position.x += _noise.get_noise_2d(_noise_time, 0.0) * log(parent_speed + 1) / 10
	position.y += _noise.get_noise_2d(_noise_time, 500.0) * log(parent_speed + 1) / 10

	# Smoothly lerp for the player's own input-driven movement.
	position += (target.global_position - Vector2(0, offset_up) - position) * delta * speed
	
	# Set scale based on the viewport height
	var camera_size = max(ceil(get_viewport_rect().size.y / 400), 1)
	zoom = Vector2(camera_size, camera_size)

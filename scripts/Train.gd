class_name Train extends StaticBody2D

signal teleported

@export var direction: int = 1           # 1 = down, -1 = up
@export var dock_duration: float = 5.0
@export var travel_duration: float = 4.0  # seconds per one station
@export var rail_x: float = 0.0
@export var initial_progress: float = 0.0
@export var speed_curve: Curve
@export var player: Node2D

var progress: float = 0.0
var _docked: bool = false
var _dock_timer: float = 0.0
var _prev_offset: int = 0
var _passengers: Dictionary = {}  # body -> original_parent

func _ready() -> void:
	if player == null:
		push_error("Train: player not set")
	progress = initial_progress
	call_deferred("_init_offset")

func _init_offset() -> void:
	_prev_offset = floori(progress - _player_spos() + 0.5)

func _player_spos() -> float:
	return StationManager.instance.get_station_pos(player.global_position.y)

func _visual_progress() -> float:
	if speed_curve == null:
		return progress
	if direction > 0:
		return speed_curve.sample(progress)
	else:
		return 1.0 - speed_curve.sample(1.0 - progress)

func _process(_delta: float) -> void:
	# Boarding: Area2D overlap works normally for bodies not yet reparented.
	for body: Node2D in $Area2D.get_overlapping_bodies():
		if body == self or body in _passengers:
			continue
		_passengers[body] = body.get_parent()
		body.reparent(self, true)

	# Deboarding: once reparented, the body vanishes from get_overlapping_bodies(),
	# so check bounds manually instead. The body's position is now local to the train.
	if not _passengers.is_empty():
		var cs := $Area2D/CollisionShape2D
		var half := (cs.shape as RectangleShape2D).size * 0.5
		var center: Vector2 = $Area2D.position + cs.position
		var to_deboard: Array[Node2D] = []
		for body: Node2D in _passengers.keys():
			var rel := body.position - center
			if absf(rel.x) > half.x or absf(rel.y) > half.y:
				to_deboard.append(body)
		for body in to_deboard:
			var orig: Node = _passengers[body]
			_passengers.erase(body)
			body.reparent(orig, true)

func _physics_process(delta: float) -> void:
	if _docked:
		_dock_timer -= delta
		if _dock_timer <= 0.0:
			_docked = false
	else:
		progress += direction * delta / travel_duration
		if direction > 0 and progress >= 1.0:
			progress = fmod(progress, 1.0)
			_docked = true
			_dock_timer = dock_duration
		elif direction < 0 and progress < 0.0:
			progress = 1.0 + fmod(progress, 1.0)
			_docked = true
			_dock_timer = dock_duration

	var vp := _visual_progress()
	var ps := _player_spos()
	var offset := floori(vp - ps + 0.5)

	if (offset - _prev_offset) * direction > 0:
		teleported.emit()
	_prev_offset = offset

	global_position = Vector2(rail_x, StationManager.instance.get_world_y(vp - offset))

class_name Train extends StaticBody2D

signal teleported

@export var direction: int = 1
@export var dock_duration: float = 5.0
@export var travel_duration: float = 4.0
@export var rail_x: float = 0.0
@export var initial_progress: float = 0.0
@export var speed_curve: Curve
@export var doors: Array[CollisionShape2D] = []
@export var nav_links: Array[NavigationLink2D] = []
@export var return_point: Node2D
@export var platform_side: int = 1
@export var player: Node2D

var progress: float = 0.0
var _docked: bool = false
var _dock_timer: float = 0.0
var _prev_offset: int = 0
var _passengers: Dictionary = {}
var _eject_pending: bool = false
var _eject_pos: Vector2 = Vector2.ZERO
var _skip_boarding: bool = false
var _current_station: int = 0  # counts arrivals; resets after depot run

func _ready() -> void:
	if player == null:
		push_error("Train: player not set")
	progress = initial_progress
	_set_doors(false)
	call_deferred("_init_offset")

func _init_offset() -> void:
	_prev_offset = floori(_visual_progress() - _player_spos() + 0.5)

func _player_spos() -> float:
	return StationManager.instance.get_station_pos(player.global_position.y)

func _visual_progress() -> float:
	if speed_curve == null:
		return progress
	if direction > 0:
		return speed_curve.sample(progress)
	else:
		return 1.0 - speed_curve.sample(1.0 - progress)

func _set_doors(open: bool) -> void:
	for door in doors:
		door.disabled = open
	for link in nav_links:
		link.enabled = open
	if open:
		_sync_nav_links()
		_request_passenger_repath()

func _sync_nav_links() -> void:
	for link: NavigationLink2D in nav_links:
		if not link.enabled:
			continue
		NavigationServer2D.link_set_start_position(link.get_rid(), link.to_global(link.start_position))
		NavigationServer2D.link_set_end_position(link.get_rid(), link.to_global(link.end_position))

func _request_passenger_repath() -> void:
	for body in _passengers.keys():
		if body.has_method("request_repath"):
			body.request_repath()

func _push_from_doors() -> void:
	for door: CollisionShape2D in doors:
		if not door.shape is RectangleShape2D:
			continue
		var half: Vector2 = (door.shape as RectangleShape2D).size * 0.5
		var center: Vector2 = door.position
		var inward := signf(-center.x) if center.x != 0.0 else 1.0
		for body: Node2D in _passengers.keys():
			var rel: Vector2 = body.position - center
			if absf(rel.x) <= half.x and absf(rel.y) <= half.y:
				body.position.x = center.x + (half.x + 1.0) * inward

func _eject_all() -> void:
	var had_player := player in _passengers
	var half_x: float = ($Area2D/CollisionShape2D.shape as RectangleShape2D).size.x * 0.5
	for body: Node2D in _passengers.keys():
		var local_y := body.position.y
		body.reparent(_passengers[body], false)
		body.global_position = Vector2(_eject_pos.x + (half_x + 10.0) * platform_side, _eject_pos.y + local_y)
		if body.has_method("disembarked"):
			body.disembarked()
	_passengers.clear()
	if had_player:
		UiConnector.instance.display_text("Terminal station. Please exit — the train is going to the depot.")

func _process(_delta: float) -> void:
	if _eject_pending:
		_eject_pending = false
		_eject_all()
		_skip_boarding = true

	if _docked and not _skip_boarding:
		for body: Node2D in $Area2D.get_overlapping_bodies():
			if body == self or body in _passengers:
				continue
			_passengers[body] = body.get_parent()
			body.reparent($Passengers, true)
			if body.has_method("boarded"):
				body.boarded(self)

	_skip_boarding = false

	if not _passengers.is_empty():
		var cs := $Area2D/CollisionShape2D
		var half := (cs.shape as RectangleShape2D).size * 0.5
		var center: Vector2 = $Area2D.position + cs.position
		var to_deboard: Array[Node2D] = []
		for body: Node2D in _passengers.keys():
			var rel := body.position - center
			if absf(rel.x) > half.x or absf(rel.y) > half.y:
				if _docked:
					to_deboard.append(body)
				else:
					body.position = return_point.position
		for body in to_deboard:
			var orig: Node = _passengers[body]
			_passengers.erase(body)
			body.reparent(orig, true)
			if body.has_method("disembarked"):
				body.disembarked()

func _physics_process(delta: float) -> void:
	if _docked:
		_dock_timer -= delta
		if _dock_timer <= 0.0:
			# Departing. Is the next leg a depot run (leaving the last station)?
			# Use world station coordinate (vp - offset) to detect the terminal,
			# since progress is only 0→1 per segment, not across the whole route.
			var vp_now := _visual_progress()
			var offset_now := floori(vp_now - _player_spos() + 0.5)
			var world_station := vp_now - offset_now
			var last_station := StationManager.instance.stop_count() - 1
			var going_to_depot := (direction > 0 and world_station >= last_station - 1) or \
								  (direction < 0 and world_station <= 1.0)
			if going_to_depot:
				_eject_pos = global_position
				_set_doors(false)
				_eject_pending = true
			else:
				_push_from_doors()
				_set_doors(false)
			progress = 0.0 if direction > 0 else 1.0
			_docked = false
	else:
		progress += direction * delta / travel_duration
		if direction > 0 and progress >= 1.0:
			progress = 1.0
			_docked = true
			_dock_timer = dock_duration
			_set_doors(true)
		elif direction < 0 and progress <= 0.0:
			progress = 0.0
			_docked = true
			_dock_timer = dock_duration
			_set_doors(true)

	var vp := _visual_progress()
	var ps := _player_spos()
	var offset := floori(vp - ps + 0.5)

	if (offset - _prev_offset) * direction > 0:
		teleported.emit()
	_prev_offset = offset

	global_position = Vector2(rail_x, StationManager.instance.get_world_y(vp - offset))
	_sync_nav_links()

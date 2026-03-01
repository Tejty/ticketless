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
	add_to_group("trains")
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

func get_passenger_pos() -> Vector2:
	var local: Vector2
	if randi() % 2 == 0:
		local = Vector2(randf_range(-14.0, 14.0), randf_range(30.0, 148.0))
	else:
		local = Vector2(randf_range(-14.0, 14.0), randf_range(-154.0, -36.0))
	return to_global(local)

func get_line_fraction() -> float:
	var vp := _visual_progress()
	var ps := _player_spos()
	var offset := floori(vp - ps + 0.5)
	var world_station := vp - offset
	var last := float(StationManager.instance.stop_count() - 1)
	if last <= 0.0:
		return 0.0
	return clampf(world_station / last, 0.0, 1.0)

func clear_npc_passengers() -> void:
	var to_remove: Array[Node2D] = []
	for body: Node2D in _passengers.keys():
		if body != player:
			to_remove.append(body)
	for body in to_remove:
		_passengers.erase(body)
		body.queue_free()

func board_npc(body: Node2D, local_pos: Vector2) -> void:
	if body in _passengers:
		return
	_passengers[body] = body.get_parent()
	body.reparent($Passengers, true)
	body.global_position = to_global(local_pos)

func deboard_npc(body: Node2D) -> void:
	if body not in _passengers:
		return
	var orig: Node = _passengers[body]
	var local_y := body.position.y
	_passengers.erase(body)
	body.reparent(orig, true)
	body.global_position = to_global(Vector2(platform_side * 50.0, local_y))

func _notify_on_dock() -> void:
	var vp := _visual_progress()
	var ps := _player_spos()
	var offset := floori(vp - ps + 0.5)
	var world_station := vp - offset
	var last := StationManager.instance.stop_count() - 1
	var station_idx := clampi(roundi(world_station), 0, last)
	var remaining := last - station_idx if direction > 0 else station_idx
	var station := StationManager.instance.stops[station_idx]
	if platform_side == 1:
		station.door_left.disabled = true
	else:
		station.door_right.disabled = true
	print("[Train] _notify_on_dock station_idx=%d remaining=%d nav_links=%d" % [station_idx, remaining, nav_links.size()])
	if remaining <= 0:
		return
	var cur_station := StationManager.instance.stops[station_idx] as Station
	print("[Train] notifying station=%s waiting_npcs=%d" % [cur_station.name, cur_station.waiting_npcs.size()])
	for body in _passengers.keys():
		if body.has_method("train_docked"):
			body.train_docked(cur_station, remaining)
	cur_station.notify_train_arrived(self, remaining)

func _set_doors(open: bool) -> void:
	for door in doors:
		door.disabled = open
	for link in nav_links:
		link.enabled = open
	if open:
		_sync_nav_links()
		_request_passenger_repath()
		call_deferred("_notify_on_dock")

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
			var station := StationManager.instance.stops[floor(world_station + 0.5)]
			if platform_side == 1:
				station.door_left.disabled = false
			else:
				station.door_right.disabled = false
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

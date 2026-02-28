# This script was made with the help of AI
class_name Train extends Node2D

signal teleported

@export var direction: int = 1        # 1 = down, -1 = up
@export var dock_duration: float = 5.0
@export var travel_duration: float = 4.0  # time to travel one full station
@export var window_before: float = 0.5   # stations before player where train appears
@export var window_after: float = 0.5   # stations past player before wrapping; must stay > 0.5
@export var rail_x: float = 0.0
@export var initial_progress: float = 0.0
@export var player: Node2D

var progress: float = 0.0
var _player_spos: float = 0.0   # exact player stationized pos, sampled at each wrap
var _dock_station: float = 0.0  # nearest integer station to player, sampled at each wrap

func _ready() -> void:
	if player == null:
		push_error("Train: player not set")
	progress = initial_progress
	call_deferred("_sample_player")

func _sample_player() -> void:
	_player_spos = StationManager.instance.get_station_pos(player.global_position.y)
	_dock_station = roundf(_player_spos)

func _physics_process(delta: float) -> void:
	progress += delta / _cycle_duration()
	if progress >= 1.0:
		progress -= 1.0
		_sample_player()
		teleported.emit()
	global_position = _position_at(progress)

func _position_at(p: float) -> Vector2:
	var sm := StationManager.instance
	var cycle := _cycle_duration()

	# Approach distance varies slightly depending on where the dock snapped to
	# relative to the exact player position. Total travel distance is always constant.
	var approach_dist := window_before + direction * (_dock_station - _player_spos)
	var t_arrive := travel_duration * approach_dist / cycle
	var t_depart := t_arrive + dock_duration / cycle

	var spos: float
	if p < t_arrive:
		spos = lerpf(_player_spos - direction * window_before,
				_dock_station, p / t_arrive)
	elif p < t_depart:
		spos = _dock_station
	else:
		spos = lerpf(_dock_station,
				_player_spos + direction * window_after,
				(p - t_depart) / (1.0 - t_depart))

	return Vector2(rail_x, sm.get_world_y(spos))

func _cycle_duration() -> float:
	return travel_duration * (window_before + window_after) + dock_duration

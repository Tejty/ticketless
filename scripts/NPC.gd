extends CharacterBody2D

@export var agent: NavigationAgent2D
@export var speed := 40.0

enum State { WAITING, LEAVING, BOARDING, ON_TRAIN, DEBOARDING }

const STATION_INTERVAL := 6.0
const TRAIN_INTERVAL := 12.0
const LEAVE_CHANCE := 0.15

var state := State.WAITING
var station: Station = null
var _train: Train = null
var _action_timer := 0.0
var _board_local: Vector2 = Vector2.ZERO  # boarding target in train-local space

@export var start: Station

func _ready() -> void:
	init(start)

func init(p_station: Station) -> void:
	station = p_station
	_action_timer = randf_range(0.0, STATION_INTERVAL)
	_pick_waiting_pos()
	if station:
		station.waiting_npcs.append(self)

func _pick_waiting_pos() -> void:
	if station:
		agent.target_position = station.get_waiting_pos()

func _pick_train_pos() -> void:
	if _train:
		agent.target_position = _train.get_passenger_pos()

func boarded(train: Train) -> void:
	if station:
		station.waiting_npcs.erase(self)
	_train = train
	state = State.ON_TRAIN
	_action_timer = randf_range(0.0, TRAIN_INTERVAL)
	_pick_train_pos()

func disembarked() -> void:
	_train = null
	state = State.WAITING
	_action_timer = randf_range(0.0, STATION_INTERVAL)
	_pick_waiting_pos()
	if station and self not in station.waiting_npcs:
		station.waiting_npcs.append(self)

func train_arrived(train: Train, remaining: int) -> void:
	if state != State.WAITING:
		return
	var board_prob := float(remaining) / float(StationManager.instance.stop_count() - 1)
	if randf() < board_prob:
		station.waiting_npcs.erase(self)
		_train = train
		state = State.BOARDING
		_action_timer = train.dock_duration + 2.0
		if randi() % 2 == 0:
			_board_local = Vector2(randf_range(-14.0, 14.0), randf_range(30.0, 148.0))
		else:
			_board_local = Vector2(randf_range(-14.0, 14.0), randf_range(-154.0, -36.0))
		agent.target_position = train.to_global(_board_local)

func train_docked(p_station: Station, remaining: int) -> void:
	if state != State.ON_TRAIN:
		return
	station = p_station
	if remaining <= 0:
		return
	if randi_range(1, remaining) == 1:
		state = State.DEBOARDING
		agent.target_position = station.get_waiting_pos()

func request_repath() -> void:
	agent.target_position = agent.target_position

func _physics_process(delta: float) -> void:
	match state:
		State.WAITING:
			_action_timer -= delta
			if _action_timer <= 0.0:
				_action_timer = STATION_INTERVAL + randf_range(-1.0, 1.0)
				if randf() < LEAVE_CHANCE and station and station.exit:
					station.waiting_npcs.erase(self)
					state = State.LEAVING
					agent.target_position = station.exit.global_position
				else:
					_pick_waiting_pos()
		State.LEAVING:
			if agent.is_navigation_finished():
				queue_free()
				return
		State.BOARDING:
			_action_timer -= delta
			if _action_timer <= 0.0:
				# Train left without us — revert to waiting
				_train = null
				state = State.WAITING
				_action_timer = randf_range(0.0, STATION_INTERVAL)
				_pick_waiting_pos()
				if station and self not in station.waiting_npcs:
					station.waiting_npcs.append(self)
			elif is_instance_valid(_train) and agent.is_navigation_finished():
				agent.target_position = _train.to_global(_board_local)
		State.ON_TRAIN:
			_action_timer -= delta
			if _action_timer <= 0.0:
				_action_timer = TRAIN_INTERVAL + randf_range(-2.0, 2.0)
				_pick_train_pos()

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	var next := agent.get_next_path_position()
	velocity = (next - global_position).normalized() * speed
	move_and_slide()

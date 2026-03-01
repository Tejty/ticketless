extends CharacterBody2D

@export var agent: NavigationAgent2D
@export var speed := 40.0
@export var talkable: Talkable

enum State { WAITING, LEAVING, BOARDING, ON_TRAIN }

const STATION_INTERVAL := 6.0
const LEAVE_CHANCE := 0.15

var state := State.WAITING
var station: Station = null
var _train: Train = null
var _action_timer := 0.0
var _board_local: Vector2 = Vector2.ZERO

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

# Called by Train if the player drags this NPC in via Area2D (fallback).
func boarded(train: Train) -> void:
	if station:
		station.waiting_npcs.erase(self)
	_train = train
	state = State.ON_TRAIN

# Called by Train._eject_all() at terminal station.
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
		# Walk to the platform side of the train door (stays on station navmesh).
		agent.target_position = train.to_global(Vector2(train.platform_side * 50.0, _board_local.y))

func train_docked(p_station: Station, remaining: int) -> void:
	if state != State.ON_TRAIN:
		return
	station = p_station
	if remaining <= 0:
		return
	if randi_range(1, remaining) == 1:
		_do_deboard()

func _do_deboard() -> void:
	if not is_instance_valid(_train):
		return
	_train.deboard_npc(self)
	_train = null
	state = State.WAITING
	_action_timer = randf_range(0.0, STATION_INTERVAL)
	_pick_waiting_pos()
	if station and self not in station.waiting_npcs:
		station.waiting_npcs.append(self)

func request_repath() -> void:
	if state == State.BOARDING:
		agent.target_position = agent.target_position

func _physics_process(delta: float) -> void:
	z_index = clampi(int(get_global_transform_with_canvas().origin.y), -4096, 4096)

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
				# Train left without us — revert to waiting.
				_train = null
				state = State.WAITING
				_action_timer = randf_range(0.0, STATION_INTERVAL)
				_pick_waiting_pos()
				if station and self not in station.waiting_npcs:
					station.waiting_npcs.append(self)
			elif is_instance_valid(_train) and agent.is_navigation_finished():
				# Reached the door — teleport into the train.
				_train.board_npc(self, _board_local)
				state = State.ON_TRAIN
		State.ON_TRAIN:
			velocity = Vector2.ZERO
			return

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	var next := agent.get_next_path_position()
	velocity = (next - global_position).normalized() * speed
	if talkable.is_talking(): return
	move_and_slide()

extends CharacterBody2D

@export var agent: NavigationAgent2D
@export var speed := 40.0

enum State { WAITING, LEAVING, BOARDING, ON_TRAIN }

var state := State.WAITING
var station: Station = null
var _train: Train = null
var _wander_timer := 0.0

const WANDER_INTERVAL := 4.0

func init(p_station: Station) -> void:
	station = p_station
	_pick_waiting_pos()

func _pick_waiting_pos() -> void:
	if station:
		agent.target_position = station.get_waiting_pos()

func boarded(train: Train) -> void:
	_train = train
	state = State.ON_TRAIN

func disembarked() -> void:
	_train = null
	state = State.WAITING
	_pick_waiting_pos()

func request_repath() -> void:
	agent.target_position = agent.target_position

func _physics_process(delta: float) -> void:
	match state:
		State.WAITING:
			_wander_timer -= delta
			if _wander_timer <= 0.0:
				_wander_timer = WANDER_INTERVAL + randf_range(-1.0, 1.0)
				_pick_waiting_pos()
		State.LEAVING:
			if agent.is_navigation_finished():
				queue_free()
		State.ON_TRAIN:
			if _train:
				agent.target_position = _train.to_global(Vector2(0, 89))

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	var next := agent.get_next_path_position()
	velocity = (next - global_position).normalized() * speed
	move_and_slide()

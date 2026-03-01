extends CharacterBody2D

@export var agent: NavigationAgent2D
@export var player: Player
@export var speed := 40.0

var _train: Train = null
var _last_target: Vector2 = Vector2.INF

func boarded(train: Train) -> void:
	_train = train

func disembarked() -> void:
	_train = null

func request_repath() -> void:
	_last_target = Vector2.INF

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var player_pos := player.global_position
	if player_pos.distance_squared_to(_last_target) > 25.0:
		agent.target_position = player_pos
		_last_target = player_pos
	if agent.is_navigation_finished():
		return
	var next := agent.get_next_path_position()
	velocity = (next - global_position).normalized() * speed
	move_and_slide()

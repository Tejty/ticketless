class_name NPCSpawner extends Node

@export var npc_variants: Array[PackedScene] = []
## Max NPCs on a train when at the middle of the line (parabolic formula).
@export var max_train_spawn_count: int = 10
## How many NPCs to place at each station on startup.
@export var initial_station_count: int = 3
## Seconds between exit-arrival ticks.
@export var exit_spawn_interval: float = 15.0
## Chance per station per tick that one NPC arrives from the exit.
@export var exit_spawn_chance: float = 0.25

var _exit_timer: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	for train: Train in get_tree().get_nodes_in_group("trains"):
		train.teleported.connect(func(): _on_teleported(train))
	_initial_station_spawn()

func _process(delta: float) -> void:
	_exit_timer -= delta
	if _exit_timer <= 0.0:
		_exit_timer = exit_spawn_interval
		_spawn_exits()

# ── teleport: repopulate train passengers ────────────────────────────────────

var _pending_trains: Array[Train] = []

func _on_teleported(train: Train) -> void:
	if train in _pending_trains:
		return
	_pending_trains.append(train)
	call_deferred("_do_repopulate_train", train)

func _do_repopulate_train(train: Train) -> void:
	_pending_trains.erase(train)
	if not is_instance_valid(train):
		return
	train.clear_npc_passengers()
	var part := train.get_line_fraction()
	var count := roundi(4.0 * part * (1.0 - part) * float(max_train_spawn_count))
	for _j in range(count):
		_spawn_on_train(train)

func _spawn_on_train(train: Train) -> void:
	var npc := _make_npc()
	if not npc:
		return
	get_parent().add_child(npc)
	var local: Vector2
	if randi() % 2 == 0:
		local = Vector2(randf_range(-14.0, 14.0), randf_range(30.0, 148.0))
	else:
		local = Vector2(randf_range(-14.0, 14.0), randf_range(-154.0, -36.0))
	train.board_npc(npc, local)
	npc.call("boarded", train)

# ── startup: seed station waiting areas ──────────────────────────────────────

func _initial_station_spawn() -> void:
	for station: Station in StationManager.instance.stops:
		for _j in range(initial_station_count):
			_spawn_waiting(station)

# ── timer: people arriving from outside ──────────────────────────────────────

func _spawn_exits() -> void:
	for station: Station in StationManager.instance.stops:
		if station.exit and randf() < exit_spawn_chance:
			_spawn_at_exit(station)

# ── helpers ───────────────────────────────────────────────────────────────────

func _spawn_waiting(station: Station) -> void:
	var npc := _make_npc()
	if not npc:
		return
	get_parent().add_child(npc)
	npc.global_position = station.get_waiting_pos()
	npc.call("init", station)

func _spawn_at_exit(station: Station) -> void:
	var npc := _make_npc()
	if not npc:
		return
	get_parent().add_child(npc)
	npc.global_position = station.exit.global_position
	npc.call("init", station)

func _make_npc() -> Node2D:
	if npc_variants.is_empty():
		return null
	return npc_variants[randi() % npc_variants.size()].instantiate()

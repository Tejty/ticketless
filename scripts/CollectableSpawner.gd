class_name CollectableSpawner extends Node

@export var collectable_variants: Array[PackedScene] = []
@export var max_station_count: int = 3
@export var chance: float = 0.5
@export var interval: float = 20
@export var player: Player

var _timer: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	_initial_station_spawn()

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = interval
		_spawn()

func _initial_station_spawn() -> void:
	for station: Station in StationManager.instance.stops:
		for _j in range(station.max_collectables):
			_spawn_on(station)

func _spawn() -> void:
	for station: Station in StationManager.instance.stops:
		var player_pos = StationManager.instance.get_station_pos(player.global_position.y)
		var station_pos = StationManager.instance.get_station_pos(station.position.y)
		if player_pos > station_pos - 0.5 and player_pos < station_pos + 0.5:
			continue
		station.max_collectables = randi_range(0, max_station_count)
		while station.collectables.size() > station.max_collectables:
			var c = station.collectables[randi_range(0, station.collectables.size() - 1)]
			c.queue_free()
			station.collectables.erase(c)
		if station.max_collectables > station.collectables.size() and randf() < chance:
			_spawn_on(station)

func _spawn_on(station: Station) -> void:
	var c := _make_collectable()
	if not c:
		return
	get_parent().add_child(c)
	c.global_position = station.get_waiting_pos()
	station.collectables.append(c)
	c.tree_exiting.connect(func(): station.collectables.erase(c))

func _make_collectable() -> Node2D:
	if collectable_variants.is_empty():
		return null
	return collectable_variants[randi() % collectable_variants.size()].instantiate()

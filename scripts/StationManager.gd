class_name StationManager extends Node

static var instance: StationManager

@export var stops: Array[Marker2D] = []

func _ready() -> void:
	instance = self
	stops.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)

## Converts a world Y position to a stationized coordinate.
## 0.0 = first stop, 1.0 = second stop, 1.5 = halfway between stop 1 and 2, etc.
## Clamped to [0, stop_count - 1].
func get_station_pos(world_y: float) -> float:
	if stops.size() < 2:
		return 0.0
	if world_y <= stops[0].global_position.y:
		return 0.0
	if world_y >= stops[-1].global_position.y:
		return float(stops.size() - 1)
	for i in range(stops.size() - 1):
		var a = stops[i].global_position.y
		var b = stops[i + 1].global_position.y
		if world_y <= b:
			return i + (world_y - a) / (b - a)
	return float(stops.size() - 1)

## Inverse of get_station_pos. Converts stationized coordinate back to world Y.
func get_world_y(station_pos: float) -> float:
	station_pos = clampf(station_pos, 0.0, stops.size() - 1)
	var i := int(station_pos)
	var t := station_pos - i
	if i >= stops.size() - 1:
		return stops[-1].global_position.y
	return lerpf(stops[i].global_position.y, stops[i + 1].global_position.y, t)

func stop_count() -> int:
	return stops.size()

class_name Player extends CharacterBody2D

var _nearby: Array[Interactable] = []
var _closest: Interactable = null
@export var stats: StatsComponent
var dead := false

signal died(cause: String)

func _physics_process(_delta: float) -> void:
	z_index = clampi(int(get_global_transform_with_canvas().origin.y), -4096, 4096)
	if dead: return
	_update_closest()
	if Input.is_action_just_pressed("interact") and _closest:
		_closest.interact(self)

func add_interactable(i: Interactable) -> void:
	_nearby.append(i)

func remove_interactable(i: Interactable) -> void:
	_nearby.erase(i)
	if is_instance_valid(i):
		i.unselect()
	if _closest == i:
		_closest = null

func _update_closest() -> void:
	var new_closest: Interactable = null
	var best_dist := INF
	for i in _nearby:
		var d = global_position.distance_squared_to(i.global_position)
		if d < best_dist:
			best_dist = d
			new_closest = i

	if new_closest == _closest:
		return

	if _closest:
		_closest.unselect()
	_closest = new_closest
	if _closest:
		_closest.select()

func _on_stats_component_starved() -> void:
	emit_signal("died", "You starved to death")


func _on_died(cause: String) -> void:
	dead = true
	UiConnector.instance.update_stats("Dead")

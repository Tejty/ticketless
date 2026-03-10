class_name Player extends CharacterBody2D

var _nearby: Array[Interactable] = []
var _closest: Interactable = null
@export var stats: StatsComponent
var dead := false

var is_selected_by_mouse := false
var lock_mouse_timeout := 0.0

signal died(cause: String)
signal won(cause: String)

func _ready() -> void:
	stats.init(self)

func _physics_process(delta: float) -> void:
	if lock_mouse_timeout > 0:
		lock_mouse_timeout -= delta
	else:
		lock_mouse_timeout = 0
		if velocity.length() > 0.8:
			is_selected_by_mouse = false
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

func _input(event):
	if event is InputEventMouseMotion:
		is_selected_by_mouse = true
		lock_mouse_timeout = 1.0

func _update_closest() -> void:
	var new_closest: Interactable = null
	var best_dist := INF
	for i in _nearby:
		var d = (get_global_mouse_position() if is_selected_by_mouse else global_position).distance_squared_to(i.global_position)
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

func report() -> void:
	emit_signal("died", "You got reported")

func win() -> void:
	emit_signal("won", "You are no longer ticketless\nDrunk %d beers in the process" % [stats.beers])

func _on_stats_component_starved() -> void:
	emit_signal("died", "You starved to death")


func _on_died(cause: String) -> void:
	dead = true
	UiConnector.instance.update_stats("Lost")


func _on_won(cause: String) -> void:
	dead = true
	UiConnector.instance.update_stats("Won")

class_name Station extends Marker2D

@export var exit: Node2D
@export var waiting_zone: CollisionShape2D
@export var door_left: CollisionShape2D
@export var door_right: CollisionShape2D

var number: int

var train_up: Train = null
var train_down: Train = null

var waiting_npcs: Array = []

func init(number: int):
	number = number

func notify_train_arrived(train: Train, remaining: int) -> void:
	waiting_npcs = waiting_npcs.filter(func(n): return is_instance_valid(n))
	for npc in waiting_npcs:
		if npc.has_method("train_arrived"):
			npc.train_arrived(train, remaining)

func get_waiting_pos() -> Vector2:
	var size := (waiting_zone.shape as RectangleShape2D).size
	var offset := size * Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	return waiting_zone.global_position + offset

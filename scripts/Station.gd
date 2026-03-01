class_name Station extends Marker2D

@export var exit: Node2D
@export var waiting_zone: CollisionShape2D

var number: int

var train_up: Train = null
var train_down: Train = null

func init(number: int):
	number = number

func get_waiting_pos() -> Vector2:
	var size := (waiting_zone.shape as RectangleShape2D).size
	var offset := size * Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	return waiting_zone.global_position + offset

class_name Station extends Marker2D

@export var exit: Node2D

var number: int

var train_up: Train = null
var train_down: Train = null

func init(number: int):
	number = number

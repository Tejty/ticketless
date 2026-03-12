extends AudioStreamPlayer2D

var last_y: float

@export var doors: AudioStreamPlayer2D

func _ready() -> void:
	last_y = (get_parent() as Node2D).position.y

func _physics_process(_delta: float) -> void:
	var new_y = (get_parent() as Node2D).position.y
	var speed = abs(new_y - last_y)
	last_y = new_y
	volume_linear = atan(speed / 5) * 2

extends AudioStreamPlayer2D

var last_y: float
var is_docked: bool

@export var doors: AudioStreamPlayer2D

func _ready() -> void:
	last_y = (get_parent() as Node2D).position.y

func _physics_process(delta: float) -> void:
	var new_y = (get_parent() as Node2D).position.y
	var speed = abs(new_y - last_y)
	last_y = new_y
	
	volume_linear = atan(speed / 5) * 2
	
	var was_docked = is_docked
	is_docked = speed == 0
	if is_docked != was_docked:
		doors.pitch_scale = 0.9 if is_docked else 1.4
		doors.play()

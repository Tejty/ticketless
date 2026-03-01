class_name MovementComponent extends Node

@export var input: InputComponent
@export var body: CharacterBody2D

@export var speed: int = 100
@export var drunk_wobble_speed: float = 60.0

var _noise := FastNoiseLite.new()
var _noise_time := 0.0

func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 0.4

func _physics_process(delta: float) -> void:
	if body is Player:
		if body.dead: return
	body.velocity = input.direction * speed

	if body is Player:
		var visual := (body as Player).stats.drunk_visual
		if visual > 0.0:
			_noise_time += delta
			var nx := _noise.get_noise_2d(_noise_time, 0.0)
			var ny := _noise.get_noise_2d(_noise_time, 100.0)
			body.velocity += Vector2(nx, ny) * drunk_wobble_speed * visual

	body.move_and_slide()

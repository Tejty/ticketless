class_name PostProcessManager extends CanvasLayer

static var instance: PostProcessManager

@onready var _mat: ShaderMaterial = $ColorRect.material as ShaderMaterial
var _drunk_time := 0.0

@export var effect := true

func _ready() -> void:
	show()
	instance = self
	if effect:
		_mat.set_shader_parameter("vignette_strength", 1.0)
		_mat.set_shader_parameter("aberration_strength", 0.004)
	else:
		_mat.set_shader_parameter("vignette_strength", 0)
		_mat.set_shader_parameter("aberration_strength", 0)
		_mat.set_shader_parameter("drunk_strength", 0)
		_mat.set_shader_parameter("drunk_time", 0)

func _process(delta: float) -> void:
	_drunk_time += delta
	if effect:
		_mat.set_shader_parameter("drunk_time", _drunk_time)

func set_drunk(strength: float) -> void:
	if effect:
		_mat.set_shader_parameter("drunk_strength", strength)

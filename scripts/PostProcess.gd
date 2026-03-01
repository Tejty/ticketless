class_name PostProcessManager extends CanvasLayer

static var instance: PostProcessManager

@onready var _mat: ShaderMaterial = $ColorRect.material as ShaderMaterial
var _drunk_time := 0.0

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	_drunk_time += delta
	_mat.set_shader_parameter("drunk_time", _drunk_time)

func set_drunk(strength: float) -> void:
	_mat.set_shader_parameter("drunk_strength", strength)

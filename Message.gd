class_name Message extends Node2D

@export var label: RichTextLabel

var _tween: Tween

func _ready() -> void:
	scale = Vector2.ZERO
	z_index += 1000

func say(text: String):
	if _tween:
		_tween.kill()
	label.text = text
	_tween = create_tween()
	scale = Vector2.ZERO
	modulate.a = 1
	_tween.tween_property(self, "scale", Vector2(0.6, 1.2), 0.1)
	_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)
	_tween.tween_interval(3.0)
	_tween.tween_property(self, "modulate:a", 0.0, 1.0)

func status(text: String):
	if _tween:
		_tween.kill()
	label.text = text
	_tween = create_tween()
	scale = Vector2.ZERO
	modulate.a = 1
	_tween.tween_property(self, "scale", Vector2(0.6, 1.2), 0.1)
	_tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

func discard():
	scale = Vector2.ZERO

extends CanvasLayer

@export var display_text: Label
@export var stats_text: Label

var _tween: Tween

func _ready() -> void:
	show()

func _on_ui_connect_called_display_text(text: String) -> void:
	if _tween:
		_tween.kill()
	display_text.modulate.a = 1.0
	display_text.text = text
	_tween = create_tween()
	_tween.tween_property(display_text, "theme_override_font_sizes/font_size", 32, 0)
	_tween.tween_property(display_text, "theme_override_font_sizes/font_size", 40, 0.1)
	_tween.tween_property(display_text, "theme_override_font_sizes/font_size", 32, 0.2)
	_tween.tween_interval(2.0)
	_tween.tween_property(display_text, "modulate:a", 0.0, 1.0)


func _on_ui_connect_called_update_stats(text: String) -> void:
	stats_text.text = text

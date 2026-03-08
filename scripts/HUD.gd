extends CanvasLayer

@export var display_text: Label
@export var stats_text: Label
@export var item_list: HBoxContainer
@export var item_template: TextureRect

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


func _on_stats_component_update_item_display(items: Array[ItemData]) -> void:
	for node in item_list.get_children():
		if node == item_template:
			continue
		node.queue_free()
	for item in items:
		var icon = item_template.duplicate()
		icon.texture = item.icon
		icon.show()
		item_list.add_child(icon)

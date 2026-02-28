class_name UiConnector extends Node

static var instance: UiConnector

signal called_display_text(text: String)
signal called_update_stats(text: String)

func _ready() -> void:
	instance = self

func display_text(text: String):
	emit_signal("called_display_text", text)

func update_stats(stats: String):
	emit_signal("called_update_stats", stats)

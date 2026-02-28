class_name UiConnector extends Node

static var instance: UiConnector

signal called_display_text(text: String)

func _ready() -> void:
	instance = self

func display_text(text: String):
	emit_signal("called_display_text", text)

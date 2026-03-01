extends CanvasLayer

@export var cause_label: Label

func _ready() -> void:
	hide()

func _on_player_died(cause: String) -> void:
	cause_label.text = cause
	show()

extends CanvasLayer

@export var cause_label: Label

func _ready() -> void:
	hide()

func _on_player_died(cause: String) -> void:
	cause_label.text = cause
	show()


func _on_button_pressed() -> void:
	hide()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

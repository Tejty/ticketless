extends "res://scripts/GrabFocus.gd"

func _on_pause_menu_visibility_changed() -> void:
	grab_focus(true)

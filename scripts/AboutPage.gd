extends Control

func _ready() -> void:
	$HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/CreditsText.meta_clicked.connect(func(meta): OS.shell_open(meta))
	$HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/AboutText.meta_clicked.connect(func(meta): OS.shell_open(meta))

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

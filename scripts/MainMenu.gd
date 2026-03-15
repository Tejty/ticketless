extends Control

func _ready() -> void:
	MusicPLayer.speed_multiplier = 1

func _on_play_pressed() -> void:
	MusicPLayer.state = MusicPLayer.MusicState.GAME
	MusicPLayer.play_next()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/tutorial_page.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_about_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/about_page.tscn")

extends "res://scripts/WinSprite.gd"

@export var other: Texture2D
@export var other_win: Texture2D

func _process(_delta: float) -> void:
	var mouse := get_local_mouse_position().x
	var player := to_local(global_position).x
	if MusicPLayer.state == MusicPLayer.MusicState.WON:
		if mouse > player:
			texture = other_win
		else:
			texture = win_texture
	else:
		if mouse > player:
			texture = other
		else:
			texture = normal

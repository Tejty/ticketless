extends TextureRect

@export var win_texture: Texture2D
var normal: Texture2D

func _ready() -> void:
	normal = texture
	if MusicPLayer.state == MusicPLayer.MusicState.WON:
		texture = win_texture

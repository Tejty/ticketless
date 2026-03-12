extends CanvasLayer

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !visible:
			show()
			get_tree().paused = true
		else:
			hide()
			get_tree().paused = false

func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_menu_pressed() -> void:
	hide()
	get_tree().paused = false
	MusicPLayer.state = MusicPLayer.MusicState.MENU
	MusicPLayer.play_next()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

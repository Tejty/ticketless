extends Sprite2D

func _on_interacted(by: Variant) -> void:
	rotate(PI/2)
	UiConnector.instance.display_text("Interacted")
	if by is Player:
		by.stats.eat(3)

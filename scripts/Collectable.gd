class_name Collectable extends Interactable


func _on_interacted(by: Variant) -> void:
	collect(by)
	queue_free()

func collect(player: Player):
	pass

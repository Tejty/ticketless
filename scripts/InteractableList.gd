extends Node

var interactable_list: Array[Interactable] = []

func add(interactable: Interactable):
	interactable_list.append(interactable)

func remove(interactable: Interactable) -> void:
	interactable_list.erase(interactable)

func get_interactables() -> Array[Interactable]:
	return interactable_list

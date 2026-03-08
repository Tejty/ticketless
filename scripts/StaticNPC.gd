extends Node2D

@export var message: Message

var quest_accepted := false
var last_actor: Node2D

func _on_interactable_interacted(by: Variant) -> void:
	last_actor = by
	if quest_accepted:
		if is_solved():
			reward()
		else:
			explain()
			quest_accepted = true
	else:
		if is_solved():
			explain_solved()
			quest_accepted = true
		else:
			explain()
			quest_accepted = true

func is_solved() -> bool:
	return false

func reward():
	message.say("You completed the quest")

func explain():
	message.say("I need you to complete the quest")

func explain_solved():
	message.say("I see you completed the quest. Want a reward?")

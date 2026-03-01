class_name Talkable extends Interactable

func interact(by: Node) -> void:
	say("Hello")

func say(message: String):
	UiConnector.instance.display_text(message)

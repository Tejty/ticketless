class_name Talkable extends Interactable

var talking_time_remaining := 0.0

func is_talking() -> bool:
	return talking_time_remaining > 0

func interact(by: Node) -> void:
	say("Hello")

func _physics_process(delta: float) -> void:
	if !is_talking(): return
	talking_time_remaining -= delta

static func say(message: String):
	UiConnector.instance.display_text(message)

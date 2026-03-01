class_name Talkable extends Interactable

var talking_time_remaining := 0.0
@export var interaction_time := 300.0
var last_actor: Node2D

func is_talking() -> bool:
	return talking_time_remaining > 0

func interact(by: Node2D) -> void:
	talking_time_remaining = interaction_time
	last_actor = by
	say("Hello")

func _physics_process(delta: float) -> void:
	if !is_talking(): return
	talking_time_remaining -= delta * (last_actor.position - position).length()

static func say(message: String):
	UiConnector.instance.display_text(message)

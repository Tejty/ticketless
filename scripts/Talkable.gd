class_name Talkable extends Interactable

var is_talking := false
var talking_time_remaining := 0.0
@export var interaction_time := 300.0
@export var questions: Array[String]
@export var accept_answers: Array[String]
@export var decline_answers: Array[String]
@export var harsh_answers: Array[String]
@export var impatient_answers: Array[String]
var last_actor: Node2D
var times_interacted = 0

func interact(by: Node2D) -> void:
	talking_time_remaining = interaction_time
	is_talking = true
	last_actor = by
	times_interacted += 1
	say("You: " + questions[randi_range(0,questions.size()-1)])

func respond():
	var harshness = randi_range(1,2)
	for i in range(times_interacted):
		harshness += randi() % 2
	var response: String
	match harshness:
		1:
			response = accept_answers[randi_range(0,accept_answers.size()-1)]
			if last_actor.has_node("StatsComponent"):
				var amount: float = ceil(randf_range(1,100))/10
				(last_actor.get_node("StatsComponent") as StatsComponent).earn(amount)
				say(response + " +$%d" % [amount])
				return
		2:
			response = decline_answers[randi_range(0,decline_answers.size()-1)]
		3:
			response = harsh_answers[randi_range(0,harsh_answers.size()-1)]
		_:
			response = impatient_answers[randi_range(0,impatient_answers.size()-1)]
	
	say(response)

func _physics_process(delta: float) -> void:
	if !is_talking: return
	talking_time_remaining -= delta * (last_actor.position - position).length()
	if talking_time_remaining <= 0:
		respond()
		is_talking = false

static func say(message: String):
	UiConnector.instance.display_text(message)

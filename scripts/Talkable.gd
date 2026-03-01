class_name Talkable extends Interactable

var is_talking := false
var talking_time_remaining := 0.0
@export var interaction_time := 5.0
@export var questions: Array[String]
@export var accept_answers: Array[String]
@export var decline_answers: Array[String]
@export var harsh_answers: Array[String]
@export var impatient_answers: Array[String]
var last_actor: Node2D
var times_interacted = 0

signal call_police()

func _ready() -> void:
	super._ready()
	call_police.connect(_on_call_police)

func _on_call_police() -> void:
	if last_actor is Player:
		last_actor.arrest()

func interact(by: Node2D) -> void:
	talking_time_remaining = interaction_time * randf_range(0.5,1)
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
				var amount: float = ceil(randf_range(1,100))/10.0
				(last_actor.get_node("StatsComponent") as StatsComponent).earn(amount)
				say(response + " +$%d" % [amount])
				return
		2:
			response = decline_answers[randi_range(0,decline_answers.size()-1)]
		3:
			response = harsh_answers[randi_range(0,harsh_answers.size()-1)]
		4,5,6,7,8:
			response = impatient_answers[randi_range(0,impatient_answers.size()-1)]
		_:
			emit_signal("call_police")
	
	say(response)

func _physics_process(delta: float) -> void:
	if !is_talking: return
	talking_time_remaining -= delta
	if talking_time_remaining <= 0:
		is_talking = false
		if last_actor.global_position.distance_squared_to(global_position) > 300.0 * 300.0:
			return
		respond()

static func say(message: String):
	UiConnector.instance.display_text(message)

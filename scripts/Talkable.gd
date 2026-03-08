class_name Talkable extends Interactable

static var active: Talkable = null

var is_talking := false
var talking_time_remaining := 0.0
@export var interaction_time := 3.0
@export var questions: Array[String]
@export var accept_answers: Array[String]
@export var decline_answers: Array[String]
@export var harsh_answers: Array[String]
@export var impatient_answers: Array[String]
@export var message_node: Message
var last_actor: Node2D
var times_interacted = 0

signal call_police()

func _ready() -> void:
	super._ready()
	call_police.connect(_on_call_police)

func _exit_tree() -> void:
	if active == self:
		active = null

func _on_call_police() -> void:
	if last_actor is Player:
		last_actor.report()

func interact(by: Node2D) -> void:
	if active != null:
		return
	active = self
	talking_time_remaining = interaction_time * randf_range(0.5,1)
	is_talking = true
	last_actor = by
	times_interacted += 1
	message_node.status("...")
	player_say(questions[randi_range(0,questions.size()-1)])

func respond():
	var harshness = randi_range(1,2)
	var additions := 1
	var benefits := 0
	if last_actor is Player:
		if last_actor.stats.drunk_timer > 0:
			additions += 2
		benefits = last_actor.stats.get_benefit_score()
	
	for i in range(max(times_interacted + additions - benefits, 0)):
		harshness += randi() % 2
	var response: String = "I'm calling police"
	match harshness:
		1:
			response = accept_answers[randi_range(0,accept_answers.size()-1)]
			if last_actor.has_node("StatsComponent"):
				var amount: int = ceil(randf_range(1,50)/10.0)
				(last_actor.get_node("StatsComponent") as StatsComponent).earn(amount)
				message_node.say(response + " +$%d" % [amount])
				return
		2, 3:
			response = decline_answers[randi_range(0,decline_answers.size()-1)]
		4:
			response = harsh_answers[randi_range(0,harsh_answers.size()-1)]
		5, 6:
			response = impatient_answers[randi_range(0,impatient_answers.size()-1)]
		_:
			emit_signal("call_police")
	
	message_node.say(response)

func _physics_process(delta: float) -> void:
	if !is_talking: return
	talking_time_remaining -= delta
	if last_actor.global_position.distance_squared_to(global_position) > 64.0 * 64.0:
		message_node.discard()
		is_talking = false
		active = null
		message_node.say("?")
		return
	if talking_time_remaining <= 0:
		is_talking = false
		active = null
		respond()

static func player_say(message: String):
	UiConnector.instance.display_text(message)

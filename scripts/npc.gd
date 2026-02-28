extends CharacterBody2D

@export var agent: NavigationAgent2D
@export var player: Player
@export var speed := 10.0

func _ready() -> void:
	agent.target_position = player.position

func _physics_process(delta: float) -> void:
	agent.target_position = player.position
	velocity = (agent.get_next_path_position() - position).normalized() * speed
	move_and_slide()

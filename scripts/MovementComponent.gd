class_name MovementComponent extends Node

@export var input: InputComponent
@export var body: CharacterBody2D

@export var speed: int = 100

func _physics_process(delta: float) -> void:
	if body is Player:
		if body.dead: return
	body.velocity = input.direction * speed
	body.move_and_slide()

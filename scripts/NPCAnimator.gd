extends AnimatedSprite2D

@export var body: CharacterBody2D
var is_anim_up := false

func _ready() -> void:
	play("idle_down")

func _process(delta: float) -> void:
	if body.velocity.y > 0:
		is_anim_up = false
	elif body.velocity.y < 0:
		is_anim_up = true
	var walking := body.velocity.length_squared() > 0
	
	if is_anim_up:
		if walking:
			animation = "walk_up"
		else:
			animation = "idle_up"
	else:
		if walking:
			animation = "walk_down"
		else:
			animation = "idle_down"

extends AnimatedSprite2D

@export var input: InputComponent
@export var body: Player
var is_anim_right := true

func _ready() -> void:
	play("idle_right")

func _process(delta: float) -> void:
	if input.direction.x < 0:
		is_anim_right = false
	elif input.direction.x > 0:
		is_anim_right = true
	var walking := body.velocity.length_squared() > 0
	
	if is_anim_right:
		if walking:
			animation = "walk_right"
		else:
			animation = "idle_right"
	else:
		if walking:
			animation = "walk_left"
		else:
			animation = "idle_left"

extends AnimatedSprite2D

@export var input: InputComponent
@export var body: Player
@export var hat: AnimatedSprite2D
@export var suit: AnimatedSprite2D
@export var hat_item: ItemData
@export var suit_item: ItemData
@export var stats: StatsComponent
var is_anim_right := true

func _ready() -> void:
	play("idle_right")
	suit.play("idle_right")
	hat.hide()
	suit.hide()

func _process(delta: float) -> void:
	if input.direction.x < 0:
		is_anim_right = false
	elif input.direction.x > 0:
		is_anim_right = true
	var walking := body.velocity.length_squared() > 0
	
	if is_anim_right:
		hat.animation = "right"
		if walking:
			animation = "walk_right"
			suit.animation = "walk_right"
		else:
			animation = "idle_right"
			suit.animation = "idle_right"
	else:
		hat.animation = "left"
		if walking:
			animation = "walk_left"
			suit.animation = "walk_left"
		else:
			animation = "idle_left"
			suit.animation = "idle_left"
	
	if stats.has(hat_item):
		hat.show()
	else:
		hat.hide()
	
	if stats.has(suit_item):
		suit.show()
	else:
		suit.hide()

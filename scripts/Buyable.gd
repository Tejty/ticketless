class_name Buyable extends Interactable

@export var message: Message
@export var price: int = 12
@export var item: ItemData
@export var sold_time: float

var sold_timer: float = 0

func interact(by: Node2D) -> void:
	if sold_timer > 0:
		return
	if by is Player:
		if by.stats.try_spend(price):
			message.say("Thanks for your order! +1 %s" % [item.name])
			by.stats.obtain(item)
			sold_timer = sold_time
		else:
			message.say("%s costs $%d" % [item.name, price])

func select():
	super()
	message.status("-$%d" % [price])

func unselect():
	super()
	message.discard()

func _physics_process(delta: float) -> void:
	if sold_timer > 0:
		outline_sprite.hide()
		sold_timer -= delta
	else:
		outline_sprite.show()
		sold_timer = 0

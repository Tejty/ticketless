class_name Seller extends Sprite2D

@export var price := 10.0
@export var product_name := "Kebab"
@export var food_value := 4

@export var message_node: Message

func _on_interactable_interacted(by: Variant) -> void:
	if by is Player:
		var stats: StatsComponent = by.get_node("StatsComponent")
		if stats.try_spend(price):
			stats.eat(food_value)
			message_node.say("Thanks for your order! +%d food" % [food_value])
		else:
			message_node.say("%s costs $%d" % [product_name, price])

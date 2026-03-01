class_name Seller extends Sprite2D

@export var price := 10.0
@export var product_name := "Kebab"
@export var food_value := 4

func _on_interactable_interacted(by: Variant) -> void:
	if by is Player:
		var stats: StatsComponent = by.get_node("StatsComponent")
		if stats.try_spend(price):
			stats.eat(food_value)
			UiConnector.instance.display_text("Thanks for your order! +%d food" % [food_value])
		else:
			UiConnector.instance.display_text("%s costs $%d" % [product_name, price])

class_name BeerSeller extends Seller

func _on_interactable_interacted(by: Variant) -> void:
	if by is Player:
		var stats: StatsComponent = by.get_node("StatsComponent")
		if stats.try_spend(price):
			stats.get_drunk(120.0)
			message_node.say("Thanks for your order! +%d food" % [food_value])
		else:
			message_node.say("%s costs $%d" % [product_name, price])

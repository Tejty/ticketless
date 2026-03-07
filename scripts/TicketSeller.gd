class_name TicketSeller extends Seller

func _on_interactable_interacted(by: Variant) -> void:
	if by is Player:
		var stats: StatsComponent = by.get_node("StatsComponent")
		if stats.try_spend(price):
			message_node.say("Thanks for your order!")
			by.win()
		else:
			message_node.say("%s costs $%d" % [product_name, price])

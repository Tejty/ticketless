extends Collectable

func collect(player: Player):
	var amount = randi_range(1,4)
	player.stats.eat(amount)
	UiConnector.instance.display_text("+%d food" % [amount])

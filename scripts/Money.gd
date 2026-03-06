class_name Money extends Collectable

func collect(player: Player):
	var amount = 0
	if randf_range(0, 1) > 0.5:
		amount = randi_range(1,10)
	else:
		amount = randi_range(1,5)
	player.stats.earn(amount)
	UiConnector.instance.display_text("+$%d" % [amount])

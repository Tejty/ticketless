extends "res://scripts/StaticNPC.gd"

@export var hat: ItemData
@export var reward_amount: int = 30
@export var npc_replacement: PackedScene

func is_solved() -> bool:
	if last_actor is Player:
		return last_actor.stats.has(hat)
	return false

func reward():
	if last_actor is Player:
		last_actor.stats.try_give(hat)
		last_actor.stats.earn(reward_amount)
		var npc = npc_replacement.instantiate()
		get_parent().add_child(npc)
		if npc is NPCCharacter:
			npc.position = position
			npc.talkable.message_node.say("Oh thank you very much! +$%d" % [reward_amount])
			npc.init(StationManager.instance.stops[round(StationManager.instance.get_station_pos(npc.position.y))])
		queue_free()

func explain():
	message.say("I lost my top hat. If you get me some, I'll pay you $%d" % [reward_amount])

func explain_solved():
	message.say("I lost my top hat, but I see you have one. Want to sell it for $%d?" % [reward_amount])

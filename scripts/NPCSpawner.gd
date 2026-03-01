class_name NPCSpawner extends Node

@export var npc_variants: Array[PackedScene] = []
@export var max_train_spawn_count = 10

func get_train_spawn_count(part: float) -> float:
	return 4*part*(1-part)*max_train_spawn_count

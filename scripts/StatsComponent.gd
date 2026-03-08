class_name StatsComponent extends Node

var money: float
var food: int
var beers: int
var player: Player
var inventory: Array[ItemData] = []
@export var max_food: int = 10

signal starved

@export var hunger_interval := 0.5
var accumulator := 0.0

var drunk_timer: float = 0.0
var drunk_visual: float = 0.0

func update_stats():
	var text = "Food: %d/%d\n$%d" % [food, max_food, money]
	if drunk_timer > 0.0:
		text += "\n*Drunk*"
	UiConnector.instance.update_stats(text)

func init(p: Player):
	self.player = p

func _ready() -> void:
	food = max_food
	call_deferred("update_stats")

func get_drunk(duration: float) -> void:
	beers += 1
	drunk_timer = max(drunk_timer, duration)
	update_stats()

func eat(value: int):
	food = min(food + value, max_food)
	update_stats()

func starve(value: int):
	food = max(food - value, 0)
	if food <= 0:
		emit_signal("starved")
		return
	update_stats()

func earn(value: float):
	money += value
	update_stats()

func try_spend(value: float) -> bool:
	if money < value: return false
	money -= value
	update_stats()
	return true

func obtain(item: ItemData):
	inventory.append(item)

func has(item: ItemData) -> bool:
	return inventory.has(item)

func try_give(item: ItemData) -> bool:
	if has(item):
		inventory.erase(item)
		return true
	return false

func _physics_process(delta: float) -> void:
	if player.dead:
		return
	
	accumulator += delta
	while accumulator >= hunger_interval:
		accumulator -= hunger_interval
		starve(1)

	if drunk_timer > 0.0:
		drunk_timer -= delta
		if drunk_timer <= 0.0:
			drunk_timer = 0.0
			update_stats()

	# Lerp visual toward target — handles both fade-in and fade-out
	var target := clampf(drunk_timer / 5.0, 0.0, 1.0)
	drunk_visual = lerpf(drunk_visual, target, delta * 1.5)
	if drunk_visual < 0.001:
		drunk_visual = 0.0
	PostProcessManager.instance.set_drunk(drunk_visual)

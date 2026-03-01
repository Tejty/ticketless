class_name StatsComponent extends Node

var money: float
var food: int
@export var max_food: int = 10

signal starved

@export var hunger_interval := 0.5
var accumulator := 0.0

func update_stats():
	UiConnector.instance.update_stats("Food: %d/%d\n$%d" % [food, max_food, money])

func _ready() -> void:
	food = max_food
	call_deferred("update_stats")

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

func _physics_process(delta: float) -> void:
	accumulator += delta
	while accumulator >= hunger_interval:
		accumulator -= hunger_interval
		starve(1)

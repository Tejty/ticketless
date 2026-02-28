class_name StatsComponent extends Node

var money: float
var food: int
@export var max_food: int = 10

signal starved

@export var hunger_interval := 0.5
var accumulator := 0.0

func update_stats():
	UiConnector.instance.update_stats("Food: %d\n$%d/%d" % [food, money, max_food])

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

func _physics_process(delta: float) -> void:
	accumulator += delta
	while accumulator >= hunger_interval:
		accumulator -= hunger_interval
		starve(1)

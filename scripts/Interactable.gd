class_name Interactable extends Area2D

signal interacted(by)

@export var prompt: String = "Press E"
@export var outline_sprite: Node2D  # Sprite2D or AnimatedSprite2D
@export var selected_color: Color = Color(1.0, 1.0, 0.0, 1.0)
@export var unselected_color: Color = Color(0.0, 1.0, 0.0, 1.0)

var outline_mat: ShaderMaterial

var _overlapping_players: Array[Player] = []

func _ready() -> void:
	InteractableList.add(self)
	_setup_outline()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _exit_tree() -> void:
	InteractableList.remove(self)
	for player in _overlapping_players:
		if is_instance_valid(player):
			player.remove_interactable(self)

func _setup_outline() -> void:
	if outline_sprite == null:
		return
	outline_mat = ShaderMaterial.new()
	outline_mat.shader = preload("uid://n6plm3bwv23")
	outline_sprite.material = outline_mat
	unselect()

func select() -> void:
	set_outline_color(selected_color)

func unselect() -> void:
	set_outline_color(unselected_color)

func set_outline_enabled(enabled: bool) -> void:
	if outline_mat:
		outline_mat.set_shader_parameter("outline_enabled", enabled)

func set_outline_color(color: Color) -> void:
	if outline_mat:
		outline_mat.set_shader_parameter("outline_color", color)

func can_interact(by: Node) -> bool:
	return true

func interact(by: Node) -> void:
	if not can_interact(by):
		return
	emit_signal("interacted", by)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_overlapping_players.append(body)
		body.add_interactable(self)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_overlapping_players.erase(body)
		body.remove_interactable(self)

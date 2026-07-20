class_name Spike
extends Area2D


func _ready() -> void:
	body_entered.connect(_check_penguin_colliding)


func _check_penguin_colliding(body: Node2D) -> void:
	if body is Player:
		GameManager.on_level_failed.emit()

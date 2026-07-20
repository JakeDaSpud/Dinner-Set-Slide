class_name DinnerSet
extends Area2D


func _ready() -> void:
	GameManager.dinner_set = self
	body_entered.connect(_check_penguin_colliding)


func _check_penguin_colliding(body: Node2D) -> void:
	if body is Player:
		GameManager.on_level_completed.emit()
		$Chair.play("penguin_sitting")

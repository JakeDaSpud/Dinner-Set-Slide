class_name DinnerSet
extends Area2D

enum DECORATION_TYPE { DINNER, TV }
@export var type: DECORATION_TYPE = DECORATION_TYPE.DINNER


func _ready() -> void:
	GameManager.dinner_set = self
	if type == DECORATION_TYPE.TV:
		$Decoration.play("tv")
	body_entered.connect(_check_penguin_colliding)


func _check_penguin_colliding(body: Node2D) -> void:
	if body is Player:
		GameManager.on_level_completed.emit()
		$Chair.play("penguin_sitting")

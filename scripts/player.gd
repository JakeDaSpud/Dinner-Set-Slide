class_name Player
extends CharacterBody2D

@export var slide_speed: float = 48.0
@export var gravity: float = 24.0

@export var left_border: float = 64
@export var right_border: float = 176

var _wall_bound: Node2D
var _facing_right: bool = true


func _ready() -> void:
	GameManager.on_level_completed.connect(_disable)
	_wall_bound = $WallBound
	$Body.play("default")


func _physics_process(delta: float) -> void:
	velocity = Vector2(slide_speed, gravity)
	if _should_turn():
		_turn()
	move_and_slide()


func _disable() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _turn() -> void:
	slide_speed *= -1
	scale.x *= -1
	_facing_right != _facing_right


func _should_turn() -> bool:
	if _wall_bound.global_position.x <= left_border && !_facing_right:
		return true
	if _wall_bound.global_position.x >= right_border && _facing_right:
		return true
	return false

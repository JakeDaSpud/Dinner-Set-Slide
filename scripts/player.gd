class_name Player
extends CharacterBody2D

@export var slide_speed: float = 48.0
@export var gravity: float = 24.0

@export var left_border: float = 64
@export var right_border: float = 176

@export var step_height: float = 2.0
@export var start_facing_left: bool = false

@export var menu_mode: bool = false
const _MENU_LEFT_SPAWN: Vector2 = Vector2(8, 0)
const _MENU_RIGHT_SPAWN: Vector2 = Vector2()

var _wall_bound: Area2D
var _facing_right: bool = true
const _OUT_OF_BOUNDS_MARGIN: float = 16
var _project_resolution: Vector2


func _ready() -> void:
	GameManager.on_level_completed.connect(_disable)
	_wall_bound = $WallBound
	$Body.play("default")
	floor_snap_length = step_height
	
	_project_resolution = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	
	if start_facing_left:
		_turn()


func _physics_process(delta: float) -> void:
	velocity = Vector2(slide_speed, gravity)
	
	if _should_turn():
		_turn()
	
	_try_step_up(delta)
	move_and_slide()
	
	if _is_out_of_bounds() && !menu_mode:
		GameManager.on_level_failed.emit()
	elif _is_out_of_bounds() && menu_mode:
		pass


func _disable() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


func _try_step_up(delta: float) -> void:
	var next_motion: Vector2 = Vector2(velocity.x, 0) * delta
	
	if test_move(global_transform, next_motion):
		var raised_transform: Transform2D = global_transform
		raised_transform.origin.y -= step_height
		
		if !test_move(raised_transform, next_motion):
			global_position.y -= step_height


func _turn() -> void:
	slide_speed *= -1
	scale.x *= -1
	_facing_right = !_facing_right


func _should_turn() -> bool:
	if _wall_bound.get_overlapping_bodies():
		#print("40")
		return true
	if _wall_bound.global_position.x <= left_border && !_facing_right:
		#print("43")
		return true
	if _wall_bound.global_position.x >= right_border && _facing_right:
		#print("46")
		return true
	return false


func _is_out_of_bounds() -> bool:
	if position.x < -_OUT_OF_BOUNDS_MARGIN:
		return true
	if position.x > _project_resolution.x + _OUT_OF_BOUNDS_MARGIN:
		return true
	if position.y < -_OUT_OF_BOUNDS_MARGIN:
		return true
	if position.y > _project_resolution.y + _OUT_OF_BOUNDS_MARGIN:
		return true
	return false

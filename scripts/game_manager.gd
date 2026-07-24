extends Node

const HOLD_TO_QUIT_DURATION: float = 2.0
var _quit_timer: float = 0.0
var _holding_quit: bool = false

const DEBUG: bool = false

enum CONTROL_TYPE { NULL, KEYBOARD, MOUSE, GAMEPAD }
var last_used_control_type: CONTROL_TYPE = CONTROL_TYPE.NULL

const YELLOW: Color = 	Color("#F0DAB1")
const ORANGE: Color = 	Color("#E39AAC")
const RED: Color = 		Color("#C45D9F")
const BLACK: Color = 	Color("#634B7D")
const BLUE: Color = 	Color("#6461C2")
const CYAN: Color = 	Color("#2BA9B4")
const GREEN: Color = 	Color("#93D4B5")
const WHITE: Color = 	Color("#F0F6E8")

const TIME_BETWEEN_LEVELS: float = 6.0

#var level_completed: bool = false
signal on_level_completed
signal on_level_failed


var _current_level: int = 0
var _levels: Dictionary[int, String] = {
	0: "res://scenes/menu.tscn",
	1: "res://scenes/levels/level_1.tscn",
	2: "res://scenes/levels/level_2.tscn",
	3: "res://scenes/levels/level_3.tscn",
	4: "res://scenes/levels/level_4.tscn",
	5: "res://scenes/levels/level_5.tscn",
	6: "res://scenes/levels/level_6.tscn",
	7: "res://scenes/levels/level_7.tscn",
	8: "res://scenes/levels/level_8.tscn",
}
var dinner_set: DinnerSet = null
var _tween: Tween = null
var _session_token: int = 0 # For tween checking if we're in the same instance of the scene
var _current_scene: Node


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("close_game"):
		_start_quit()
	if event.is_action_released("close_game"):
		_stop_quit()
	if event.is_action_pressed("restart_level"):
		_deferred_restart_level()
	
	if event is InputEventKey:
		last_used_control_type = CONTROL_TYPE.KEYBOARD
	elif event is InputEventMouse:
		last_used_control_type = CONTROL_TYPE.MOUSE
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_used_control_type = CONTROL_TYPE.GAMEPAD


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_current_scene = get_tree().current_scene
	on_level_completed.connect(_next_level)
	on_level_failed.connect(_deferred_restart_level)


func _next_level():
	_session_token += 1
	var _tween_start_session_token: int = _session_token
	
	_tween_camera(4)
	await get_tree().create_timer(TIME_BETWEEN_LEVELS).timeout
	
	# Swapped scene during tween, abort
	if _tween_start_session_token != _session_token:
		return
	
	dinner_set = null
	_load_level(_current_level+1)
	if _tween:
		_tween.kill()
		_tween = null


func _tween_camera(duration: float) -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)
	
	_tween.tween_property(camera, "zoom", Vector2(3, 3), duration)
	_tween.tween_property(camera, "global_position", dinner_set.global_position, duration)
	
	_tween.play()


func _start_game():
	_load_level(1)


func _process(delta: float) -> void:
	if _holding_quit:
		_quit_timer += delta
	
	if _quit_timer >= HOLD_TO_QUIT_DURATION:
		_quit()
	
	if DEBUG:
		_debug_load_level()


func _deferred_restart_level() -> void:
	call_deferred("_restart_level")

 
func _restart_level() -> void:
	_session_token += 1
	if _tween:
		_tween.kill()
		_tween = null
	_load_level(_current_level)


func _load_level(level: int) -> void:
	if _levels.has(level):
		_current_level = level
		get_tree().change_scene_to_file(_levels[_current_level])
	else:
		print("Level " + str(level) + " not found.")


func _debug_load_level() -> void:
	if Input.is_key_pressed(KEY_0):
		_load_level(0)
	elif Input.is_key_pressed(KEY_1):
		_load_level(1)
	elif Input.is_key_pressed(KEY_2):
		_load_level(2)
	elif Input.is_key_pressed(KEY_3):
		_load_level(3)
	elif Input.is_key_pressed(KEY_4):
		_load_level(4)
	elif Input.is_key_pressed(KEY_5):
		_load_level(5)
	elif Input.is_key_pressed(KEY_6):
		_load_level(6)
	elif Input.is_key_pressed(KEY_7):
		_load_level(7)
	elif Input.is_key_pressed(KEY_8):
		_load_level(8)
	elif Input.is_key_pressed(KEY_9):
		_load_level(9)


func _show_credits() -> void:
	if _current_level == 0:
		get_tree().root.get_node("Game/CreditsHeader").hide()
		get_tree().root.get_node("Game/Title/Ice/Credits").queue_free()
		get_tree().root.get_node("Game/Credits").show()


func _start_quit() -> void:
	_holding_quit = true


func _stop_quit() -> void:
	_holding_quit = false
	_quit_timer = 0.0


func _quit() -> void:
	get_tree().quit()

class_name Star
extends Area2D

const _PLAYER_ROCK_DEGREE: float = 20.0
const _PLAYER_ROCK_DURATION: float = 4.5
var _player_rock_tween: Tween

const _LIGHT_ENERGY_MIN: float = 0.3
const _LIGHT_ENERGY_MAX: float = 0.4
const _LIGHT_ENERGY_DURATION: float = 3.0

const _LIGHT_RANGE_MIN: float = 0.7
const _LIGHT_RANGE_MAX: float = 0.78
const _LIGHT_RANGE_DURATION: float = 4.5
var _visuals_tween: Tween

@export var is_player: bool = false
@export var burn_damage: float = 5.0
@export var burn_radius: float = 5.0
@export var burn_interval: float = 0.1
var ice_in_range: Array[Ice] = []


func _ready() -> void:
	_set_stats()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if is_player:
		GameManager.on_level_completed.connect(_disappear)


func _disappear() -> void:
	if _player_rock_tween.is_running():
		_player_rock_tween.kill()
	if _visuals_tween.is_running():
		_visuals_tween.kill()
	
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(
		self, "scale",
		Vector2.ZERO,
		0.3
	)
	disappear_tween.finished.connect(queue_free)


func _on_body_entered(body: Node2D) -> void:
	if body is Ice:
		ice_in_range.append(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Ice:
		ice_in_range.erase(body)


func _set_stats() -> void:
	# so the player will not turn when it sees the player star in front of it
	if is_player:
		set_collision_layer_value(3, false)
		_rock_setup()
	_visuals_setup()
	
	var new_shape = CircleShape2D.new()
	new_shape.radius = burn_radius
	$CollisionShape2D.shape = new_shape
	
	$Timer.wait_time = burn_interval
	$Timer.timeout.connect(_burn)
	$Timer.start()


func _rock_setup() -> void:
	_player_rock_tween = create_tween()
	_player_rock_tween.set_loops()
	_player_rock_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	_player_rock_tween.tween_property(
		$AnimatedSprite2D, "rotation",
		$AnimatedSprite2D.rotation + _PLAYER_ROCK_DEGREE,
		_PLAYER_ROCK_DURATION
	)
	
	_player_rock_tween.tween_property(
		$AnimatedSprite2D, "rotation",
		$AnimatedSprite2D.rotation - _PLAYER_ROCK_DEGREE,
		_PLAYER_ROCK_DURATION
	)


func _visuals_setup() -> void:
	_visuals_tween = create_tween()
	_visuals_tween.set_loops()
	_visuals_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_visuals_tween.set_parallel(true)
	
	# Both to Min
	# Energy down to MIN
	_visuals_tween.tween_property(
		$PointLight2D, "energy",
		_LIGHT_ENERGY_MIN,
		_LIGHT_ENERGY_DURATION
	)
	# Range down to MIN
	_visuals_tween.tween_property(
		$PointLight2D.texture, "fill_to",
		Vector2(0.5, _LIGHT_RANGE_MIN),
		_LIGHT_RANGE_DURATION
	)
	
	_visuals_tween.chain()
	
	# Both to Max
	# Energy up to MAX
	_visuals_tween.tween_property(
		$PointLight2D, "energy",
		_LIGHT_ENERGY_MAX,
		_LIGHT_ENERGY_DURATION
	)
	# Range up to MAX
	_visuals_tween.tween_property(
		$PointLight2D.texture, "fill_to",
		Vector2(0.5, _LIGHT_RANGE_MAX),
		_LIGHT_RANGE_DURATION
	)


func _physics_process(_delta: float) -> void:
	if is_player and GameManager.last_used_control_type == GameManager.CONTROL_TYPE.MOUSE:
		self.position = get_global_mouse_position()
	else:
		var move_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var snapped_pos: Vector2 = Vector2(snapped(self.position.x, 4), snapped(self.position.y, 4))
		self.position = snapped_pos + (move_dir * 4)


func _burn() -> void:
	for ice in ice_in_range:
		ice.update_melt_progress(burn_damage)

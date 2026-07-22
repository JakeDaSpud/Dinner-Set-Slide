class_name Star
extends Area2D

const _PLAYER_STAR_MOVE_SPEED: float = 8.0
@export var is_player: bool = false
@export var burn_damage: float = 5.0
@export var burn_radius: float = 5.0
@export var burn_interval: float = 0.2
var ice_in_range: Array[Ice] = []


func _ready() -> void:
	_set_stats()
	_check_collisions()


func _set_stats() -> void:
	# so the player will not turn when it sees the player star in front of it
	if is_player:
		set_collision_layer_value(3, false)
	
	var new_shape = CircleShape2D.new()
	new_shape.radius = burn_radius
	$CollisionShape2D.shape = new_shape
	
	$Timer.wait_time = burn_interval
	$Timer.timeout.connect(_burn)
	$Timer.start()


func _input(event: InputEvent) -> void:
	if is_player and GameManager.last_used_control_type == GameManager.CONTROL_TYPE.MOUSE:
		self.position = get_global_mouse_position()
	else:
		var move_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		var snapped_pos: Vector2 = Vector2(snapped(self.position.x, 8), snapped(self.position.y, 8))
		self.position = (snapped_pos * (move_dir * 8))
	
	_check_collisions()
	
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	#	_burn()


func _check_collisions() -> void:
	ice_in_range.clear()
	for body in get_overlapping_bodies():
		if body is Ice:
			ice_in_range.append(body)


func _burn() -> void:
	for ice in ice_in_range:
		ice.update_melt_progress(burn_damage)

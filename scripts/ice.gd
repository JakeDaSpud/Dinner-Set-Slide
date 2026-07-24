class_name Ice
extends StaticBody2D

enum SIZE { NULL, LARGE, MIDDLE, SMALL, MELTED }

const ICE_LARGE: Texture2D = preload("res://assets/ice1.tres")
const ICE_MIDDLE: Texture2D = preload("res://assets/ice2.tres")
const ICE_SMALL: Texture2D = preload("res://assets/ice3.tres")

const MELT_FLASH_MODULATE: Color = GameManager.CYAN
var _og_modulate: Color
@export var flash_duration: float = 0.3
var _timer: Timer

@export var size: SIZE = SIZE.NULL
var _rectangle_shape: RectangleShape2D
@export var melt_progress: float = -1 # 100 is large, 60 turns to middle, 30 turns to small, 0 is melted!


func _ready() -> void:
	_timer = $Timer
	_timer.wait_time = flash_duration
	_timer.one_shot = true
	_timer.timeout.connect(_unflash)
	
	_og_modulate = $Sprite.modulate
	
	self.size = SIZE.LARGE
	_rectangle_shape = RectangleShape2D.new()
	_change_collision_shape(8, 8)
	
	self.melt_progress = 100


func _change_collision_shape(x: int, y: int) -> void:
	_rectangle_shape.size = Vector2(x, y)
	$PlayerCollision.shape = _rectangle_shape


func update_melt_progress(decrement: float = 1) -> void:
	melt_progress -= decrement
	
	_flash()
	
	if melt_progress <= 0:
		_melt()
	
	elif melt_progress <= 30:
		_change_to_small()
	
	elif melt_progress <= 60:
		_change_to_middle()


func _flash() -> void:
	$Sprite.modulate = MELT_FLASH_MODULATE
	_timer.start()


func _unflash() -> void:
	$Sprite.modulate = _og_modulate


func _change_to_middle() -> void:
	self.size = SIZE.MIDDLE
	_change_collision_shape(6, 6)
	$Sprite.texture = ICE_MIDDLE


func _change_to_small() -> void:
	self.size = SIZE.SMALL
	_change_collision_shape(4, 4)
	$Sprite.texture = ICE_SMALL


func _melt() -> void:
	self.size = SIZE.MELTED
	$PlayerCollision.disabled = true
	$Sprite.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED

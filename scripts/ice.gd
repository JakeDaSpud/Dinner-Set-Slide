class_name Ice
extends StaticBody2D

enum SIZE { NULL, LARGE, MIDDLE, SMALL, MELTED }
enum MENU_OPTION { NULL, REGENERATE, START, CREDITS, QUIT, MENU }

const ICE_LARGE: Texture2D = preload("res://assets/ice1.tres")
const ICE_MIDDLE: Texture2D = preload("res://assets/ice2.tres")
const ICE_SMALL: Texture2D = preload("res://assets/ice3.tres")

const MELT_FLASH_MODULATE: Color = GameManager.CYAN
var _og_modulate: Color
@export var flash_duration: float = 0.3
var _timer: Timer

@export var _menu_option: MENU_OPTION = MENU_OPTION.NULL
var size: SIZE = SIZE.NULL
var _rectangle_shape: RectangleShape2D
var melt_progress: float = -1 # 100 is large, 60 turns to middle, 30 turns to small, 0 is melted!


func _ready() -> void:
	_timer = $Timer
	_timer.wait_time = flash_duration
	_timer.one_shot = true
	_timer.timeout.connect(_unflash)
	
	_og_modulate = $Sprite.modulate
	_rectangle_shape = RectangleShape2D.new()
	
	self.size = SIZE.LARGE
	_change_collision_shape(6, 6)
	
	self.melt_progress = 100


func _change_collision_shape(x: int, y: int, delta_y_pos: int = 0) -> void:
	_rectangle_shape.size = Vector2(x, y)
	$PlayerCollision.shape = _rectangle_shape
	
	if delta_y_pos != 0:
		$PlayerCollision.position = Vector2($PlayerCollision.position.x, $PlayerCollision.position.y + delta_y_pos)
		$Sprite.position = Vector2($Sprite.position.x, $Sprite.position.y + delta_y_pos)


func update_melt_progress(decrement: float = 1) -> void:
	melt_progress -= decrement
	
	_flash()
	
	if melt_progress <= 0:
		_melt()
	
	elif melt_progress <= 30 && size == SIZE.MIDDLE:
		_change_to_small()
	
	elif melt_progress <= 60 && size == SIZE.LARGE:
		_change_to_middle()


func _flash() -> void:
	$Sprite.modulate = MELT_FLASH_MODULATE
	_timer.start()


func _unflash() -> void:
	$Sprite.modulate = _og_modulate


func _change_to_small() -> void:
	self.size = SIZE.SMALL
	_change_collision_shape(2, 2, 1)
	$Sprite.texture = ICE_SMALL
	AudioManager.play_sound(AudioManager.SOUND_TYPE.ICE_BREAK_MIDDLE)


func _change_to_middle() -> void:
	self.size = SIZE.MIDDLE
	_change_collision_shape(4, 4, 1)
	$Sprite.texture = ICE_MIDDLE
	AudioManager.play_sound(AudioManager.SOUND_TYPE.ICE_BREAK_LARGE)


func _change_to_large() -> void:
	self.size = SIZE.LARGE
	_change_collision_shape(6, 6, -2)
	$Sprite.texture = ICE_LARGE
	# No audio here


func _melt() -> void:
	if _menu_option != MENU_OPTION.NULL:
		if _menu_option == MENU_OPTION.REGENERATE:
			_regen()
			return
		elif _menu_option == MENU_OPTION.START:
			GameManager._start_game()
		elif _menu_option == MENU_OPTION.CREDITS:
			GameManager._show_credits()
		elif _menu_option == MENU_OPTION.QUIT:
			GameManager._quit()
		elif _menu_option == MENU_OPTION.MENU:
			GameManager._load_level(0)
	
	self.size = SIZE.MELTED
	$PlayerCollision.disabled = true
	$Sprite.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	AudioManager.play_sound(AudioManager.SOUND_TYPE.ICE_BREAK_SMALL)


func _regen() -> void:
	_change_to_large()
	self.melt_progress = 100

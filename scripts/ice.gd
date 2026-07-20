class_name Ice
extends StaticBody2D

enum SIZE { NULL, LARGE, MIDDLE, SMALL, MELTED }

const ICE_LARGE: Texture2D = preload("res://assets/ice1.tres")
const ICE_MIDDLE: Texture2D = preload("res://assets/ice2.tres")
const ICE_SMALL: Texture2D = preload("res://assets/ice3.tres")

@export var size: SIZE = SIZE.NULL
@export var melt_progress: int = -1 # 100 is large, 60 turns to middle, 30 turns to small, 0 is melted!


func _ready() -> void:
	self.size = SIZE.LARGE
	self.melt_progress = 100


func _update_melt_progress(decrement: int = 1) -> void:
	melt_progress -= decrement
	
	if melt_progress <= 0:
		_melt()
		return
	
	if melt_progress <= 30:
		_change_to_small()
		return
	
	if melt_progress <= 60:
		_change_to_middle()
		return


func _change_to_middle() -> void:
	self.size = SIZE.MIDDLE
	$Sprite.texture = ICE_MIDDLE


func _change_to_small() -> void:
	self.size = SIZE.SMALL
	$Sprite.texture = ICE_SMALL


func _melt() -> void:
	self.size = SIZE.MELTED
	$PlayerCollision.disabled = true
	$Sprite.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	pass

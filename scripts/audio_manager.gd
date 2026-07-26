extends Node

enum SOUND_TYPE {
	MENU,
	LEVEL,
	
	ICE_BREAK_LARGE,
	ICE_BREAK_MIDDLE,
	ICE_BREAK_SMALL,
	
	BOUNCE,
	WIN,
}

const _SFX_MENU: AudioStreamMP3 = preload("res://assets/audio/Menu.mp3")
const _SFX_LEVEL: AudioStreamMP3 = preload("res://assets/audio/Level.mp3")
const _SFX_LARGE_ICE_BREAK: AudioStreamMP3 = preload("res://assets/audio/Large Ice Break.mp3")
const _SFX_MIDDLE_ICE_BREAK: AudioStreamMP3 = preload("res://assets/audio/Middle Ice Break.mp3")
const _SFX_SMALL_ICE_BREAK: AudioStreamMP3 = preload("res://assets/audio/Small Ice Break.mp3")
const _SFX_BOUNCE: AudioStreamMP3 = preload("res://assets/audio/Bounce.mp3")
const _SFX_WIN: AudioStreamMP3 = preload("res://assets/audio/Win.mp3")

var _sounds: Dictionary[SOUND_TYPE, AudioStreamMP3] = {
	SOUND_TYPE.MENU: _SFX_MENU,
	SOUND_TYPE.LEVEL: _SFX_LEVEL,
	SOUND_TYPE.ICE_BREAK_LARGE: _SFX_LARGE_ICE_BREAK,
	SOUND_TYPE.ICE_BREAK_MIDDLE: _SFX_MIDDLE_ICE_BREAK,
	SOUND_TYPE.ICE_BREAK_SMALL: _SFX_SMALL_ICE_BREAK,
	SOUND_TYPE.BOUNCE: _SFX_BOUNCE,
	SOUND_TYPE.WIN: _SFX_WIN,
}
var _pool: Array[AudioStreamPlayer]
var _in_use_mask: Array[int]
const _POOL_SIZE: int = 16

var _music_asp: AudioStreamPlayer
var _volume_tween: Tween
const _DUCK_TIME: float = 0.7


func _ready() -> void:
	_music_asp = AudioStreamPlayer.new()
	add_child(_music_asp)
	
	_pool.resize(_POOL_SIZE)
	_in_use_mask.resize(_POOL_SIZE)
	
	for i in range(_POOL_SIZE):
		var _new_asp: AudioStreamPlayer = AudioStreamPlayer.new()
		_new_asp.finished.connect(_release.bind(_new_asp))
		add_child(_new_asp)
		
		_pool[i] = _new_asp
		_in_use_mask[i] = 0


func _acquire() -> AudioStreamPlayer:
	for asp_in_use in _in_use_mask:
		if asp_in_use == 0:
			return _pool[asp_in_use]
	print("No AudioStreamPlayers available")
	return null


func _release(asp: AudioStreamPlayer) -> void:
	var result: int = _pool.find(asp)
	if result >= 0:
		# Win SFX done, make music tween back up
		if asp.stream == _sounds[SOUND_TYPE.WIN]:
			_restore_music()
		
		asp.stream = null
		asp.pitch_scale = 1.0
		_in_use_mask[result] = 0


func play_sound(type: SOUND_TYPE) -> void:
	var _asp: AudioStreamPlayer = _acquire()
	if !_asp:
		return
	
	_asp.pitch_scale = randf_range(0.9, 1.1)
	_asp.stream = _sounds[type]
	if type == SOUND_TYPE.WIN:
		_duck_music()
	
	_asp.play()


func stop_all_sounds() -> void:
	for _asp in _pool:
		_asp.stop()
		_asp.finished.emit()


func play_music(type: SOUND_TYPE) -> void:
	# Don't reset same music
	if _sounds[type] == _music_asp.stream:
		return
	
	_music_asp.stop()
	_music_asp.stream = _sounds[type]
	_music_asp.play()


func _duck_music() -> void:
	_volume_tween = create_tween()
	_volume_tween.tween_property(_music_asp, "volume_linear", 0.0, _DUCK_TIME)
	_volume_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _restore_music() -> void:
	_volume_tween = create_tween()
	_volume_tween.tween_property(_music_asp, "volume_linear", 1.0, _DUCK_TIME * 2)
	_volume_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

extends Node2D

var fade_tween: Tween

const DEFAULT_FADE_DURATION := 0.35
const DROP_FADE_DURATION := 3.0
var call_is_dropped := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState and GameState.has_signal("menu_opened") and GameState.has_signal("menu_closed"):
		GameState.menu_opened.connect(_on_menu_opened)
		GameState.menu_closed.connect(_on_menu_closed)
	GameState.connect('half_timer', _on_half_timer)
	GameState.connect('score_changed', _on_score_changed)


func _on_score_changed(score: int):
	call_is_dropped = false
	fade_out(DROP_FADE_DURATION)


func _on_half_timer():
	if !call_is_dropped:
		call_is_dropped = true
		fade_in(DROP_FADE_DURATION)


func _on_menu_opened():
	if !call_is_dropped:
		fade_in(DEFAULT_FADE_DURATION)


func _on_menu_closed():
	if !call_is_dropped:
		fade_out(DEFAULT_FADE_DURATION)


func fade_out(duration: float = DEFAULT_FADE_DURATION) -> Tween:
	_kill_fade_tween()
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(self, "modulate:a", 0.0, max(duration, 0.0))
	return fade_tween


func fade_in(duration: float = DEFAULT_FADE_DURATION) -> Tween:
	_kill_fade_tween()
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(self, "modulate:a", 1.0, max(duration, 0.0))
	return fade_tween


func _kill_fade_tween() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

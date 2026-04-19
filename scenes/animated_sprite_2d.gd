extends AnimatedSprite2D

const DEFAULT_FADE_DURATION := 0.35
var fade_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameState and GameState.has_signal("menu_opened") and GameState.has_signal("menu_closed"):
		GameState.menu_opened.connect(_on_menu_opened)
		GameState.menu_closed.connect(_on_menu_closed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_opened():
	fade_out(DEFAULT_FADE_DURATION)


func _on_menu_closed():
	fade_in(DEFAULT_FADE_DURATION)


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

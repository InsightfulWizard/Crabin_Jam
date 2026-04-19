extends Node2D

@onready var progress_bar: ProgressBar = $ProgressBar

var timing := false
var tween : Tween
var jitter_factor: float = 0.0
const MAX_JITTER := 3.0
var pos_initial: Vector2

func _ready() -> void:
	pos_initial = position
	start_timer()
	


func _physics_process(delta: float) -> void:
	if timing:
		position = pos_initial + jitter_factor * Vector2( randf_range(-MAX_JITTER, MAX_JITTER), randf_range(-MAX_JITTER, MAX_JITTER) )


func start_timer(time: float = GameState.time_per_phrase):
	if !Constants.USE_SPEECH_TIMER: return
	timing = true
	if tween and tween.is_valid():
		tween.kill()
	progress_bar.value = 0.0
	jitter_factor = 0.0
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(progress_bar, 'value', 100.0, time)
	tween.set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, 'jitter_factor', 1.0, time)
	await tween.finished
	timing = false
	Util.hud.submit_output_trays()
	start_timer()

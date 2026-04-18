extends Node2D

@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	GameState.connect('score_changed', _on_score_change)
	progress_bar.value = 60.0


func _on_score_change(score:int):
	print('score: ', score)
	var score_percent: float = progress_bar.value - (float(score) / float(Constants.MAX_SCORE) * 100.0)
	if score_percent < 0.0:
		score_percent = 0.0
		GameState.win()
		
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(progress_bar, 'value', score_percent, .5)
	#progress_bar.value = score_percent

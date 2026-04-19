extends Node2D

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var water_surface: AnimatedSprite2D = $ProgressBar/water_surface


func _ready() -> void:
	GameState.connect('score_changed', _on_score_change)
	progress_bar.value = 100.0 - 100.0 * float(GameState.current_score) / float(Constants.MAX_SCORE)
	water_surface.position.y = get_water_surface_pos_y(progress_bar.value)


func _on_score_change(score: int):
	var score_percent: float = 100.0 - 100.0 * float(GameState.current_score) / float(Constants.MAX_SCORE)
	print('score_percent: ', score_percent)
	print('GameState.current_score: ', GameState.current_score)
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(progress_bar, 'value', score_percent, .5)

	var new_water_surface_pos: Vector2 = Vector2(water_surface.position.x, get_water_surface_pos_y(score_percent))
	tween.parallel().tween_property(water_surface, 'position', new_water_surface_pos, .5)
	#progress_bar.value = score_percent


func get_water_surface_pos_y(progress_value: float) -> float:
	var height: float = progress_bar.size.y
	return height * (100.0 - progress_value) / 100.0


func get_progress(): #returns 0 - 1 progress
	return progress_bar.value / 100.0

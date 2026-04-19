extends Node2D

var hovered_tile = null
var current_tile = null

var hovered_snap = null
var current_snap = null

var current_score: int = 0
var time_per_phrase: float = 15.0

signal score_changed(score: int)


func get_current_score() -> int:
	return current_score


func set_current_score(score:int):
	score = clamp(score, Constants.MIN_SCORE, Constants.MAX_SCORE)
	current_score = score
	emit_signal('score_changed', score)


func set_hovered_tile(tile:Node2D):
	if hovered_tile == tile:
		return
	if hovered_tile:
		hovered_tile.scale = Vector2.ONE
	tile.scale = Vector2.ONE * 1.2
	hovered_tile = tile


func clear_hovered_tile():
	hovered_tile = null


func win():
	print('You\'ve convinced them!  Your shell did not crack under the pressure!')

extends Node2D

var hovered_tile = null
var current_tile = null

var hovered_snap = null
var current_snap = null

var current_score: int = Constants.MAX_SCORE * .6
var recent_score: int = 0
var time_per_phrase: float = 15.0
var score_decrement_per_round: int = Constants.SCORE_DECREMENT_PER_ROUND_INITIAL

var rules_engine: RulesEngine = RulesEngine.new()

enum {
	DREAD,
	STRESSED,
	CHILLIN,
}
var state := STRESSED

signal score_changed(score: int)


func get_current_score() -> int:
	return current_score


func set_current_score(score: int):
	recent_score = score
	current_score = clamp(current_score + score, Constants.MIN_SCORE, Constants.MAX_SCORE)
	if score == Constants.MAX_SCORE:
		win()
	if score > Constants.CHILLIN_THRESH:
		state = CHILLIN
	elif score < Constants.DREAD_THRESH:
		state = DREAD
	else:
		state = STRESSED

	emit_signal('score_changed', current_score)


func set_hovered_tile(tile: Node2D):
	if hovered_tile == tile:
		return
	if hovered_tile:
		hovered_tile.scale = Vector2.ONE
	tile.scale = Vector2.ONE * 1.2
	hovered_tile = tile


func clear_hovered_tile():
	if hovered_tile:
		hovered_tile.scale = Vector2.ONE
	hovered_tile = null


func win():
	print('You\'ve convinced them!  Your shell did not crack under the pressure!')

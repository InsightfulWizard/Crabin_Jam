extends Node2D

var hovered_tile = null
var current_tile = null

var hovered_snap = null
var current_snap = null

var current_score: int = Constants.MAX_SCORE * .6
var recent_score: int = 0
var time_per_phrase: float = 15.0
var score_decrement_per_round: int = Constants.SCORE_DECREMENT_PER_ROUND_INITIAL


var is_menu_open := true
var game_started:= false

enum {
	DREAD,
	STRESSED,
	CHILLIN,
}
var state := STRESSED

signal score_changed(score: int)
signal menu_opened
signal menu_closed


func _input(_event):
	if Input.is_action_just_pressed('escape'):
		toggle_menu_open()

func toggle_menu_open():
	is_menu_open = !is_menu_open
	
	if is_menu_open:
		#get_tree().paused = true
		emit_signal('menu_opened')
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		#get_tree().paused = false
		emit_signal('menu_closed')
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func start_game():
	game_started = true
	print('game_started')
	Util.hud.speech_timer_bar.resume()
	


func get_current_score() -> int:
	return current_score


func set_current_score(score: int):
	recent_score = score
	current_score = clamp(current_score + score - score_decrement_per_round, Constants.MIN_SCORE, Constants.MAX_SCORE)
	if current_score == Constants.MAX_SCORE:
		win()
	if current_score > Constants.CHILLIN_THRESH:
		state = CHILLIN
	elif current_score < Constants.DREAD_THRESH:
		state = DREAD
	else:
		state = STRESSED

	print('----- new_state: ', state)

	emit_signal('score_changed', current_score)


func set_hovered_tile(tile: Node2D):
	if hovered_tile == tile:
		return
	if hovered_tile:
		if hovered_tile.has_method("set_hover_visual"):
			hovered_tile.set_hover_visual(false)
	if tile.has_method("set_hover_visual"):
		tile.set_hover_visual(true)
	hovered_tile = tile


func clear_hovered_tile():
	if hovered_tile and hovered_tile.has_method("set_hover_visual"):
		hovered_tile.set_hover_visual(false)
	hovered_tile = null


func win():
	print('You\'ve convinced them!  Your shell did not crack under the pressure!')

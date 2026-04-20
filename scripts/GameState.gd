extends Node2D

var hovered_tile = null
var current_tile = null

var hovered_snap = null
var current_snap = null

var current_score: int = roundi(float(Constants.MAX_SCORE) * .6)
var recent_score: int = 0
var time_per_phrase: float = 30.0
var score_decrement_per_round: int = Constants.SCORE_DECREMENT_PER_ROUND_INITIAL

var is_menu_open := true
var game_started := false
var rules_engine: RulesEngine = RulesEngine.new()

var potential_score = 0

enum {
	DREAD,
	STRESSED,
	CHILLIN,
}
var state := STRESSED

signal score_changed(score: int)
signal state_changed(new_state: int)
signal menu_opened
signal menu_closed
signal half_timer
signal potential_score_changed(score: int)


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
	if !game_started:
		game_started = true
		AudioManager._on_state_change(state)
	Util.hud.speech_timer_bar.resume()


func get_current_score() -> int:
	return current_score


func set_current_score(score: int): # replace the other one
	recent_score = score
	current_score = clamp(current_score + score, Constants.MIN_SCORE, Constants.MAX_SCORE)
	if current_score == Constants.MAX_SCORE:
		win()
	if current_score == Constants.MIN_SCORE:
		lose()
	if current_score > Constants.CHILLIN_THRESH:
		change_state(CHILLIN)
	elif current_score < Constants.DREAD_THRESH:
		change_state(DREAD)
	else:
		change_state(STRESSED)

	emit_signal('score_changed', current_score)


func change_state(s: int):
	if state == s:
		return
	state = s
	emit_signal('state_changed', s)


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


func exit_game():
	get_tree().quit()


func win():
	emit_signal('menu_opened')
	Util.menu.switch_to_menu(Util.menu.WIN)
	print('You\'ve convinced them!  Your shell did not crack under the pressure!')

func lose():
	emit_signal('menu_opened')
	Util.menu.switch_to_menu(Util.menu.LOSE)


func update_potential_score():
	Util.hud.grade_output_tray_potential()

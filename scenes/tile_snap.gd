extends Node2D

@onready var col = $"shake_container/Area2D"
@onready var label: Label = $shake_container/Label
@onready var blank_penalty_text: Label = $shake_container/blank_penalty_text
@onready var shake_container: Node2D = $shake_container

@onready var indicator_container: Node2D = $indicator_container
@onready var indicator: ColorRect = $indicator_container/indicator
@onready var ligature: ColorRect = $indicator_container/ligature


var snapped_tile: Node2D
var snapped_index: int = -1
var slot_index: int = -1
var active: bool = true

var blank_penalty := 0
var current_penalties = Constants.PENALTY_TABLE
const filler_words: Array[String] = [
	'umm',
	'uhh',
	'hmm',
	'err',
	'...',
	'uh',
	'..I.',
	'um',
	'er..',
	'...',
	'..h.',
	'..!.',
	'..?.',
]

var jitter_factor: float = .1 #pixels
var jitter_factor_anim: float = 0 #pixels
var jitter_tween: Tween

var good_color := Color(0.578, 0.608, 0.218, 1.0)
var bad_color := Color(0.75, 0.11, 0.22)
var indicator_tween: Tween


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)
	assign_rand_filler_word()
	assign_rand_blank_penalty()
	GameState.connect('game_start', start_jitter)
	GameState.connect('game_won', end_jitter)
	GameState.connect('game_reset', end_jitter)
	
	GameState.connect('timer_start', _on_timer_start)
	GameState.connect('half_timer', _on_half_timer)
	indicator.color.a = 0.0
	ligature.color.a = 0.0


func _physics_process(_delta: float) -> void:
	if blank_penalty == 0 or snapped_tile or !GameState.game_started or !active:
		shake_container.position = Vector2.ZERO
		return
	if !Engine.get_physics_frames() % 5 == 0:
		return
	var rand := Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var score: float = Util.hud.score.get_progress() + .5
	shake_container.position = jitter_factor_anim * float(blank_penalty) * rand * score


func on_mouse_entered():
	GameState.hovered_snap = self


func on_mouse_exited():
	if GameState.hovered_snap == self:
		GameState.hovered_snap = null


func to_snap(tile: Node2D) -> bool:
	if !active:
		return false
	return get_parent().place_at(self, tile)


func can_snap_tile(tile: Node2D) -> bool:
	if !active:
		return false
	return get_parent().can_place_at(slot_index, tile)


func unsnap():
	if !snapped_tile:
		return
	get_parent().unsnap_tile(snapped_tile)


func delete_tile():
	if !snapped_tile:
		return
	var tile = snapped_tile
	get_parent().unsnap_tile(tile)
	tile.delete()


func assign_rand_filler_word():
	var w: String = filler_words[randi_range(0, len(filler_words) - 1)]
	label.text = w


func assign_rand_blank_penalty():
	var i: int = randi_range(0, len(current_penalties) - 1)
	blank_penalty = current_penalties[i]
	blank_penalty_text.text = str(blank_penalty)


func start_jitter():
	#print('------start jitter')
	if jitter_tween and jitter_tween.is_valid():
		jitter_tween.kill()
	jitter_tween = create_tween()
	jitter_tween.tween_property(self, 'jitter_factor_anim', jitter_factor, 2.0)


func end_jitter():
	if jitter_tween and jitter_tween.is_valid():
		jitter_tween.kill()
	jitter_tween = create_tween()
	jitter_tween.tween_property(self, 'jitter_factor_anim', 0.0, 2.0)


func set_indicator(state:int, add_ligature:bool = false):
	if state == 0:
		indicator.color.a = 0.0
	elif state == 1:
		indicator.color = good_color
	elif state == 2:
		indicator.color = bad_color
	if add_ligature:
		if state == 0:
			ligature.color.a = 0.0
		elif state == 1:
			ligature.color = good_color
		elif state == 2:
			ligature.color = bad_color
	else:
		ligature.color.a = 0.0


func _on_timer_start():
	if Constants.HIDE_MATCH_INDICATOR_ON_HALF_TIME:
		tween_indicator(true)


func _on_half_timer():
	if Constants.HIDE_MATCH_INDICATOR_ON_HALF_TIME:
		tween_indicator(false)


func tween_indicator(b:bool):
	if indicator_tween and indicator_tween.is_valid():
		indicator_tween.kill()
	indicator_tween = get_tree().create_tween()
	indicator_tween.set_trans(Tween.TRANS_QUAD)
	indicator_tween.set_ease(Tween.EASE_OUT)
	if b:
		indicator_tween.tween_property(indicator_container, "scale", Vector2.ONE, .5)
	else:
		indicator_tween.tween_property(indicator_container, "scale", Vector2.ONE * .2, 15.0)

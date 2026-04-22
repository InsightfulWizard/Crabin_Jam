extends Node2D

@onready var l1: Node2D = $l1
@onready var l2: Node2D = $l1/l2
@onready var l3: Node2D = $l1/l2/l3

@onready var ls := [
	l1, l2, l3
]

var rot_range: float = 1.0
const TWOPI: float = 6.28318530718
var time: float = 0.0

var freq: float = 3.0
var phase: float = .2
var amp: float = .3
var amp_anim_factor: float = 1.0
var rand: float
var rand_anim_factor: float = 1.0
var clench: float = PI/3.0

var lost := false


func _ready() -> void:
	rand = randf_range(0,TWOPI)
	GameState.connect('crab_boiled', _on_crab_boiled)
	GameState.connect('game_reset', _on_game_reset)


func _physics_process(delta: float) -> void:
	if lost:
		return
	var score:float =  Util.hud.score.get_progress()
	var freq_val:float = .9 + freq * score * 1.5
	#if Util.crab.moving_tween and Util.crab.moving_tween.is_valid():
		#freq_val = Util.crab.moving_tween.progress
	time = fmod( (time + freq_val*delta), TWOPI )
	for i in range(len(ls)):
		var l:Node2D =  ls[i]
		#var r_phase = ( float(i+1)*2.0 / float(len(ls) ) )
		var random: float = rand * rand_anim_factor * score 
		var amplitude: float = amp*amp_anim_factor
		var r_phase = TWOPI*phase*i + random
		var clench_val:float = .1 + clench * score
		if i == 0:
			clench_val = 0.0
		if l.is_in_group('arm'):
			clench_val *= -.3
		var rot: float = sin(time + r_phase) * amplitude + clench_val
		l.rotation = rot


func _on_crab_boiled():
	lost = true
	for i in range(len(ls)):
		var l:Node2D =  ls[i]
		var r: float = PI/3.0
		if i == 0: 
			r = -.5
		if l.is_in_group('arm'):
			r *= -.3
			if i == 1: 
				r = -.7
		l.rotation = r


func _on_game_reset():
	lost = false

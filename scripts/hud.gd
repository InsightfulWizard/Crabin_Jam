extends CanvasLayer

@onready var output_tray_1: Node2D = $output_tray_1
@onready var output_tray_2: Node2D = $output_tray_2
@onready var speech_timer_bar: Node2D = $speech_timer_bar
@onready var score: Node2D = $score

@onready var output_trays: Array[Node2D] = [
	output_tray_1,
	output_tray_2,
]
var current_output_tray: int = 0
var cycling_output_tray: bool = false


func _ready() -> void:
	Util.hud = self
	output_tray_2.position.x = get_viewport().get_visible_rect().size.x
	output_tray_2.set_snaps_active(false)


func to_hud_space(n: Node2D):
	if !n:
		return
	var glob_xform = n.global_transform
	n.get_parent().remove_child(n)
	add_child(n)
	n.global_transform = glob_xform


func submit_output_trays():
	grade_output_tray()
	cycle_output_trays()
	reset_potential()
	speech_timer_bar.start_timer()


func grade_output_tray():
	var solution = "".join(output_trays[current_output_tray].get_output_values())
	GameState.rules_engine.evaluate_solution(solution)
	print("Solution: '%s' | Score: %d" % [solution, GameState.recent_score])
	# print("vals: ", vals)
	#grading logic


func grade_output_tray_potential():
	var solution = "".join(output_trays[current_output_tray].get_output_values())
	GameState.rules_engine.evaluate_potential_score(solution)


func reset_potential():
	GameState.potential_score = 0
	GameState.emit_signal('potential_score_changed', 0)


func cycle_output_trays():
	if cycling_output_tray:
		return
	cycling_output_tray = true
	var current = output_trays[current_output_tray]
	var next = output_trays[(current_output_tray + 1) % 2]
	var size_x = get_viewport().get_visible_rect().size.x

	current.set_snaps_active(false)

	var tween: Tween = Util.tween_2d(current, "position", current.position - Vector2(size_x, 0), .6)

	Util.tween_2d(next, "position", next.position - Vector2(size_x, 0), .6)

	await tween.finished
	current.position.x = size_x
	current.reset()
	next.set_snaps_active(true)
	current_output_tray = (current_output_tray + 1) % 2
	cycling_output_tray = false

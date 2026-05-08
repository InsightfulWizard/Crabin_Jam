extends CanvasLayer

@onready var output_tray_1: Node2D = $output_tray_1
@onready var output_tray_2: Node2D = $output_tray_2
@onready var speech_timer_bar: Node2D = $speech_timer_bar
@onready var score: Node2D = $score

@onready var output_trays: Array[Node2D] = [
	output_tray_1,
	output_tray_2,
]
@onready var points_popup: Node2D = $"points popup"

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
	GameState.reset_potential()
	speech_timer_bar.start_timer()


func grade_output_tray():
	var solution = "".join(output_trays[current_output_tray].get_output_values())
	GameState.rules_engine.evaluate_solution(solution)
	print("Solution: '%s' | Score: %d" % [solution, GameState.recent_score])
	points_popup.go(GameState.recent_score)


func grade_output_tray_potential():
	var solution = "".join(output_trays[current_output_tray].get_output_values())
	GameState.rules_engine.evaluate_potential_score(solution)


func set_rule_match_visuals(pos_matches: Array[RegExMatch], neg_matches:Array[RegExMatch]):
	var snaps = output_trays[current_output_tray].get_sorted_snaps()
	for snap in snaps:
		snap.set_indicator(0)
	for m in pos_matches:
		var start := m.get_start()
		var end := m.get_end()
		if start == -1:
			continue
		for i in range(end - start):
			var add_ligature: bool  =  start + i != end - 1
			snaps[start + i].set_indicator(1, add_ligature)
	for m in neg_matches:
		var start := m.get_start()
		var end := m.get_end()
		if start == -1:
			continue
		for i in range(end - start):
			var add_ligature: bool  =  start + i != end- 1
			snaps[start + i].set_indicator(2, add_ligature)


func clear_rule_match_visuals(tray:int):
	for snap in output_trays[tray].get_sorted_snaps():
		snap.set_indicator(0)


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
	clear_rule_match_visuals(current_output_tray)
	next.set_snaps_active(true)
	current_output_tray = (current_output_tray + 1) % 2
	cycling_output_tray = false
	GameState.update_potential_score()


func get_blank_penalty() -> int:
	return output_trays[current_output_tray].get_blank_penalty()

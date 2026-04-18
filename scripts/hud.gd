extends CanvasLayer

@onready var output_tray_1 = $output_tray_1
@onready var output_tray_2 = $output_tray_2

var rules_engine: RulesEngine = RulesEngine.new()

var output_trays: Array[Node2D] = [
	output_tray_1,
	output_tray_2,
]

var current_output_tray: int = 0


func _ready() -> void:
	Util.hud = self


func to_hud_space(n: Node2D):
	if !n:
		return
	var glob_xform = n.global_transform
	n.get_parent().remove_child(n)
	add_child(n)
	n.global_transform = glob_xform


func get_output_values():
	var vals: Array[String] = []
	#for n in output_trays[current_output_tray].get_children():
	for n in output_tray_1.get_children():
		if !n.is_in_group('tile_snap'):
			continue
		if !n.snapped_tile:
			vals.append(Constants.EMPTY_TILE_VALUE)
			continue
		vals.append(n.snapped_tile.to_string())
	return vals


func get_solution():
	return "".join(get_output_values())


func score_solution():
	var solution = get_solution()
	rules_engine.evaluate_solution(solution)
	print("Solution: '%s' | Score: %d" % [solution, rules_engine.get_current_score()])

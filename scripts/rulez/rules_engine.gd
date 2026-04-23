class_name RulesEngine
extends Node

var _ruleset: Array[Rule] = []


func _init() -> void:
	generate_ruleset()


func get_ruleset() -> Array[Rule]:
	return _ruleset


func evaluate_solution(solution: String) -> void:
	var total_score = 0

	for rule in _ruleset:
		var matches = rule.pattern.search_all(solution)
		total_score += matches.size() * rule.score
	var blank_penalty: int = Util.hud.get_blank_penalty()
	total_score += blank_penalty
	GameState.set_current_score(total_score)


func evaluate_potential_score(solution: String) -> void:
	var total_score = 0

	for rule in _ruleset:
		var matches = rule.pattern.search_all(solution)
		total_score += matches.size() * rule.score
	var blank_penalty: int = Util.hud.get_blank_penalty()
	total_score += blank_penalty
	GameState.potential_score = total_score
	GameState.emit_signal('potential_score_changed', total_score)


func generate_rule(length: int):
	var id = randi()
	var pattern = ""
	while true:
		for i in range(length):
			pattern += Constants.ALPHABET[randi() % Constants.ALPHABET.length()]

		var score = length * Constants.BASE_SCORE
		if length >= 3:
			score += Constants.BASE_SCORE
		var new_rule = Rule.new(id, pattern, score)
		if not rule_exists(new_rule):
			_ruleset.append(new_rule)
			break


func generate_ruleset() -> void:
	for rule_size in [2, 2, 3]:
		generate_rule(rule_size)


func rule_exists(_candidate_rule: Rule) -> bool:
	for rule in _ruleset:
		if rule.pattern.get_pattern() == _candidate_rule.pattern.get_pattern():
			return true
	return false


func clear_ruleset() -> void:
	_ruleset.clear()


func reset_ruleset() -> void:
	clear_ruleset()
	generate_ruleset()


func print_ruleset() -> void:
	print("Current Ruleset:")
	for rule in _ruleset:
		print(rule)

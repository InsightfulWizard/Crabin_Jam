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

	GameState.set_current_score(total_score)


func evaluate_potential_score(solution: String) -> void:
	var total_score = 0

	for rule in _ruleset:
		var matches = rule.pattern.search_all(solution)
		total_score += matches.size() * rule.score

	GameState.potential_score = total_score
	GameState.emit_signal('potential_score_changed', total_score)


func generate_rule() -> Rule:
	var id = randi()
	var length = randi_range(Constants.MIN_RULE_LENGTH, Constants.MAX_RULE_LENGTH)
	var pattern = ""
	for i in range(length):
		pattern += Constants.ALPHABET[randi() % Constants.ALPHABET.length()]
	return Rule.new(id, pattern, length * Constants.BASE_SCORE)


func generate_ruleset() -> void:
	var num_rules = randi_range(Constants.MIN_RULES, Constants.MAX_RULES)
	for i in range(num_rules):
		while true:
			var new_rule = generate_rule()
			if not rule_exists(new_rule):
				_ruleset.append(new_rule)
				break
	_append_empty_rule()


func rule_exists(_candidate_rule: Rule) -> bool:
	for rule in _ruleset:
		if rule.pattern.get_pattern() == _candidate_rule.pattern.get_pattern():
			return true
	return false


func _append_empty_rule() -> void:
	var empty_rule = Rule.new(
		len(_ruleset),
		Constants.EMPTY_TILE_VALUE,
		Constants.PENALTY_EMPTY_TILE,
	)
	_ruleset.append(empty_rule)


func clear_ruleset() -> void:
	_ruleset.clear()


func generate_solution() -> String:
	var length = randi_range(Constants.MIN_SOLUTION_LENGTH, Constants.MAX_SOLUTION_LENGTH)
	var solution = ""
	for i in range(length):
		solution += Constants.ALPHABET[randi() % Constants.ALPHABET.length()]
	return solution


# For testing and debugging purposes, we can generate a static ruleset instead of a random one.
func generate_static_ruleset() -> void:
	_ruleset = [
		Rule.new(1, "△○", 20),
		Rule.new(2, "○□", 15),
		Rule.new(3, "△□", 10),
	]
	_append_empty_rule()


func reset_ruleset() -> void:
	clear_ruleset()
	generate_ruleset()


func print_ruleset() -> void:
	print("Current Ruleset:")
	for rule in _ruleset:
		print(rule)

class_name RulesEngine
extends Node

var _ruleset: Array[Rule] = []

var _current_score: int = 0


signal score_changed(score: int)


func _init() -> void:
	# generate_ruleset()
	generate_static_ruleset() # TODO: remove this and uncomment the above for actual gameplay
	print_ruleset()


func get_current_score() -> int:
	return _current_score


func set_current_score(score:int):
	_current_score = score
	emit_signal('score_changed', score)


func get_ruleset() -> Array[Rule]:
	return _ruleset


func evaluate_solution(solution: String) -> void:
	var total_score = 0

	for rule in _ruleset:
		var matches = rule.pattern.search_all(solution)
		total_score += matches.size() * rule.score
	
	total_score = clamp(total_score, Constants.MIN_SCORE, Constants.MAX_SCORE)
	set_current_score(total_score)


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
		_ruleset.append(generate_rule())
	_append_empty_rule()


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

# ---


# Internal Class to represent a scoring rule
class Rule:
	var id: int
	var pattern: RegEx
	var score: int


	func _init(_id: int, _pattern: String, _score: int=) -> void:
		self.id = _id
		self.pattern = RegEx.create_from_string(_pattern)
		self.score = _score


	func _to_string() -> String:
		return "Rule(id: %d, pattern: '%s', score: %d)" % [id, pattern.get_pattern(), score]

# --- Testing functions


# For testing and debugging purposes, we can generate a static ruleset instead of a random one.
func generate_static_ruleset() -> void:
	_ruleset = [
		Rule.new(1, "△○", 20),
		Rule.new(2, "○□", 15),
		Rule.new(3, "△□", 10),
	]
	_append_empty_rule()


func print_ruleset() -> void:
	print("Current Ruleset:")
	for rule in _ruleset:
		print(rule)

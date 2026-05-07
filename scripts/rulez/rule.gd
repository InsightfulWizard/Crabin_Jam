class_name Rule
extends Node

# Internal Class to represent a scoring rule

var id: int
var pattern: RegEx
var score: int


func _init(_id: int, _pattern: String, _score: int=) -> void:
	self.id = _id
	self.pattern = RegEx.create_from_string(_pattern)
	self.score = _score


func _to_string() -> String:
	return "Rule(id: %d, pattern: '%s', score: %d)" % [id, pattern.get_pattern(), score]

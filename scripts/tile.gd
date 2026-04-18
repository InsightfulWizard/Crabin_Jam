extends Node2D

@onready var col = $Area2D

var snap: Node2D
var value: String = Constants.EMPTY_TILE_VALUE


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)

	value = _generate_value()


func _to_string() -> String:
	return value


func _generate_value() -> String:
	var _value = ""
	for i in range(randi_range(Constants.MIN_RULE_LENGTH, Constants.MAX_RULE_LENGTH)):
		_value += Constants.ALPHABET[randi_range(0, Constants.ALPHABET.length() - 1)]
	return _value


func on_mouse_entered():
	GameState.set_hovered_tile(self)


func on_mouse_exited():
	if GameState.hovered_tile == self:
		GameState.clear_hovered_tile()
		scale = Vector2.ONE

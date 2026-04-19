class_name RuleUI
extends Control

@onready var pattern_layer: Node2D = $PatternLayer
@onready var score_label: Label = $ScoreLabel

const SYMBOL_START := Vector2(-300, 0)

var image_map = {
	"△": preload("res://art/tiles/triangle.png"),
	"○": preload("res://art/tiles/circle.png"),
	"□": preload("res://art/tiles/square.png"),
}

var rule: Rule
var symbol_scale := Vector2(0.5, 0.5)
var score_font_size := 320
var symbol_gap: float = 280.0
var score_gap: float = 320.0


func _ready() -> void:
	pattern_layer.z_index = 10
	_rebuild_visuals()


func set_rule(new_rule: Rule) -> void:
	rule = new_rule
	if is_node_ready():
		_rebuild_visuals()


func _rebuild_visuals() -> void:
	if pattern_layer == null:
		return

	for child in pattern_layer.get_children():
		child.queue_free()

	if rule == null:
		return

	var pattern_string := rule.pattern.get_pattern()
	var symbol_count := 0

	for i in range(pattern_string.length()):
		var symbol := pattern_string.substr(i, 1)
		if !image_map.has(symbol):
			continue

		var sprite := Sprite2D.new()
		sprite.texture = image_map[symbol]
		sprite.position = SYMBOL_START + Vector2(symbol_gap * symbol_count, 0)
		sprite.scale = symbol_scale
		pattern_layer.add_child(sprite)
		symbol_count += 1

	if score_label != null:
		if rule.score >= 0:
			score_label.text = "+" + str(rule.score)
		else:
			score_label.text = str(rule.score)

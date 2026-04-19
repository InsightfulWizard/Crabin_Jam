extends Control

@onready var pattern_layer = $PatternLayer

var ruleset: Array[Rule] = []
const RULE_UI_SCENE := preload("res://scenes/ui/rule.tscn")

var rule_start_position := Vector2(-28.0, 4.0)

var rule_ui_scale := Vector2(0.6, 0.6)

var rule_vertical_offset := 54.0

var max_visible_rules := 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ruleset = GameState.rules_engine.get_ruleset()
	_rebuild_rule_rows()


func _rebuild_rule_rows() -> void:
	if !is_node_ready():
		return

	for child in pattern_layer.get_children():
		child.queue_free()

	var displayed_count := 0
	for rule in ruleset:
		if displayed_count >= max_visible_rules:
			break

		var rule_ui := RULE_UI_SCENE.instantiate() as RuleUI
		rule_ui.set_rule(rule)
		pattern_layer.add_child(rule_ui)
		displayed_count += 1

	_layout_rule_rows()


func _layout_rule_rows() -> void:
	if !is_node_ready():
		return

	var start_position_local := _to_layer_local(rule_start_position)
	var vertical_offset_local := _to_layer_local(Vector2(0, rule_vertical_offset)).y

	for i in range(pattern_layer.get_child_count()):
		var rule_ui := pattern_layer.get_child(i) as RuleUI
		if rule_ui == null:
			continue

		rule_ui.scale = rule_ui_scale
		rule_ui.position = start_position_local + Vector2(0, vertical_offset_local * i)


func _to_layer_local(value: Vector2) -> Vector2:
	var canvas_scale: Vector2 = pattern_layer.get_global_transform_with_canvas().get_scale()
	var sx: float = canvas_scale.x
	var sy: float = canvas_scale.y

	if is_zero_approx(sx):
		sx = 1.0
	if is_zero_approx(sy):
		sy = 1.0

	return Vector2(value.x / sx, value.y / sy)

extends Control

@onready var pattern_layer = $PatternLayer

var ruleset: Array[Rule] = []
const RULE_UI_SCENE := preload("res://scenes/ui/rule.tscn")

var rule_start_position := Vector2(-28.0, 4.0)

var rule_ui_scale := Vector2(0.6, 0.6)

var rule_vertical_offset := 54.0
var rule_fade_duration := 0.35

var max_visible_rules := 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ruleset = GameState.rules_engine.get_ruleset()
	_rebuild_rule_rows()
	_connect_menu_signals()
	_sync_rows_with_menu_state(false)


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
	_sync_rows_with_menu_state(false)


func _connect_menu_signals() -> void:
	if !GameState:
		return

	if !GameState.has_signal("menu_opened") or !GameState.has_signal("menu_closed"):
		return

	if !GameState.menu_opened.is_connected(_on_menu_opened):
		GameState.menu_opened.connect(_on_menu_opened)

	if !GameState.menu_closed.is_connected(_on_menu_closed):
		GameState.menu_closed.connect(_on_menu_closed)


func _on_menu_opened() -> void:
	for child in pattern_layer.get_children():
		var rule_ui := child as RuleUI
		if rule_ui == null:
			continue
		rule_ui.fade_out(rule_fade_duration)


func _on_menu_closed() -> void:
	for child in pattern_layer.get_children():
		var rule_ui := child as RuleUI
		if rule_ui == null:
			continue
		rule_ui.fade_in(rule_fade_duration)


func _sync_rows_with_menu_state(animated: bool = true) -> void:
	if !GameState:
		return

	if GameState.is_menu_open:
		for child in pattern_layer.get_children():
			var rule_ui := child as RuleUI
			if rule_ui == null:
				continue
			rule_ui.fade_out(rule_fade_duration if animated else 0.0)
	else:
		for child in pattern_layer.get_children():
			var rule_ui := child as RuleUI
			if rule_ui == null:
				continue
			rule_ui.fade_in(rule_fade_duration if animated else 0.0)


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

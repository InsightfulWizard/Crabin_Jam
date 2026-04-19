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
var fade_tween: Tween

const DEFAULT_FADE_DURATION := 0.35


func _ready() -> void:
	pattern_layer.z_index = 10
	_rebuild_visuals()


func set_rule(new_rule: Rule) -> void:
	rule = new_rule
	if GameState and GameState.has_signal("menu_opened") and GameState.has_signal("menu_closed"):
		GameState.menu_opened.connect(_on_menu_opened)
		GameState.menu_closed.connect(_on_menu_closed)
	if is_node_ready():
		_rebuild_visuals()


func _on_menu_opened():
	fade_out(DEFAULT_FADE_DURATION)


func _on_menu_closed():
	fade_in(DEFAULT_FADE_DURATION)


func fade_out(duration: float = DEFAULT_FADE_DURATION) -> Tween:
	_kill_fade_tween()
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(self, "modulate:a", 0.0, max(duration, 0.0))
	return fade_tween


func fade_in(duration: float = DEFAULT_FADE_DURATION) -> Tween:
	_kill_fade_tween()
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(self, "modulate:a", 1.0, max(duration, 0.0))
	return fade_tween


func _kill_fade_tween() -> void:
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = null


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

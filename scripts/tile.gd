extends Node2D

@onready var col = $Area2D
@onready var pattern_layer = $PatternLayer
@onready var thought_ui: Control = $fancier_ui
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

var image_map = {
	"△": preload("res://art/tiles/triangle.png"),
	"○": preload("res://art/tiles/circle.png"),
	"□": preload("res://art/tiles/square.png"),
}

const HOVER_SCALE_FACTOR := 1.2
const SYMBOL_BASE_SCALE := Vector2(0.095, 0.095)
const TILE_GROUP_Z_INDEX := 20

var snap: Node2D
var group_values: Array[String] = _generate_group_values()
var slot_gap: float = 64
var is_fading_out: bool = false
var fade_tween: Tween
signal placed_in_field
signal picked_up_from_field
signal placed_in_slot
signal picked_up_from_slot
signal faded_out
var is_in_slot: bool = false
var last_field_global_position: Vector2 = Vector2.ZERO
var is_hovered_visual: bool = false
var thought_base_size: Vector2 = Vector2.ZERO
var thought_base_scale: Vector2 = Vector2.ONE
var is_menu_blocking_fade: bool = false


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)

	# value = group_values[0]
	z_as_relative = false
	z_index = TILE_GROUP_Z_INDEX
	thought_base_size = thought_ui.size
	thought_base_scale = thought_ui.scale
	_build_symbol_pattern()
	_update_thought_bubble_width()
	_update_interaction_bounds()

	#TODO: JUICE POINT
	modulate.a = 1.0
	last_field_global_position = global_position

	if GameState and GameState.has_signal("menu_opened") and GameState.has_signal("menu_closed"):
		GameState.menu_opened.connect(_on_menu_opened)
		GameState.menu_closed.connect(_on_menu_closed)
		is_menu_blocking_fade = GameState.is_menu_open

	_set_interaction_enabled(not is_menu_blocking_fade)

	attempt_fade_out()


func _build_symbol_pattern():
	for c in pattern_layer.get_children():
		c.queue_free()

	for i in range(group_values.size()):
		var symbol = group_values[i]
		if !image_map.has(symbol):
			continue
		var s = Sprite2D.new()
		s.texture = image_map[symbol]
		s.position = Vector2(slot_gap * i, 0)
		s.scale = SYMBOL_BASE_SCALE
		_set_base_scale(s, SYMBOL_BASE_SCALE)
		pattern_layer.add_child(s)

	_apply_hover_scale_to_visuals()


func _for_each_visual_sprite(callable: Callable):
	for child in pattern_layer.get_children():
		if child is Sprite2D:
			callable.call(child)


func _set_base_scale(sprite: Sprite2D, base_scale: Vector2):
	if !sprite:
		return
	sprite.set_meta("base_scale", base_scale)


func _apply_hover_scale_to_visuals():
	if thought_ui:
		var thought_factor = HOVER_SCALE_FACTOR if is_hovered_visual else 1.0
		thought_ui.scale = thought_base_scale * thought_factor
		_recenter_thought_bubble()

	_for_each_visual_sprite(
		func(sprite: Sprite2D):
			if !sprite.has_meta("base_scale"):
				_set_base_scale(sprite, sprite.scale)
			var base_scale: Vector2 = sprite.get_meta("base_scale")
			var factor = HOVER_SCALE_FACTOR if is_hovered_visual else 1.0
			sprite.scale = base_scale * factor
	)


func set_hover_visual(hovered: bool):
	is_hovered_visual = hovered
	_apply_hover_scale_to_visuals()


func _recenter_thought_bubble():
	if !thought_ui:
		return
	var group_center = get_group_center_offset()
	var half_size = (thought_ui.size * thought_ui.scale) * 0.5
	thought_ui.position = group_center - half_size


func _update_thought_bubble_width():
	if !thought_ui:
		return
	if thought_base_size == Vector2.ZERO:
		thought_base_size = thought_ui.size

	var extra_width = max(0.0, float(get_slot_length() - 1) * slot_gap)
	var scale_x = absf(thought_base_scale.x)
	if is_zero_approx(scale_x):
		scale_x = 1.0

	thought_ui.size = Vector2(thought_base_size.x + (extra_width / scale_x), thought_base_size.y)
	_recenter_thought_bubble()


func _get_base_tile_size() -> Vector2:
	if !thought_ui:
		return Vector2(64, 64)
	if thought_base_size == Vector2.ZERO:
		thought_base_size = thought_ui.size
	return thought_base_size * thought_base_scale.abs()


func _update_interaction_bounds():
	if !collision_shape:
		return

	if collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()

	var rect_shape := collision_shape.shape as RectangleShape2D
	if !rect_shape:
		return

	var tile_size = _get_base_tile_size()
	var extra_width = max(0.0, float(get_slot_length() - 1) * slot_gap)
	rect_shape.size = Vector2(tile_size.x + extra_width, tile_size.y)
	collision_shape.position = Vector2(extra_width * 0.5, 0)


func attempt_fade_out() -> void:
	if is_in_slot:
		return

	if is_menu_blocking_fade:
		return

	if GameState.current_tile == self:
		get_tree().create_timer(1.0).timeout.connect(attempt_fade_out)
		return

	if not is_fading_out:
		is_fading_out = true

		var stay_time = randf_range(2.0, 4.0) # TODO: could make dependent on score?

		#TODO: JUICE POINT
		# Face outtween sequence:
		fade_tween = create_tween()
		fade_tween.tween_interval(stay_time)
		fade_tween.tween_property(self, "modulate:a", 0.0, 0.8)

		fade_tween.finished.connect(_on_fade_out_finished)


func _on_fade_out_finished() -> void:
	if is_in_slot:
		is_fading_out = false
		return
	emit_signal("faded_out")
	queue_free()


func interrupt_fade():
	is_fading_out = false
	if fade_tween and fade_tween.is_running():
		fade_tween.kill() # STOP the animation immediately

	#TODO: JUICE POINT
	modulate.a = 1.0 # Snap back to fully visible


func _on_menu_opened():
	is_menu_blocking_fade = true
	_set_interaction_enabled(false)
	if not is_in_slot:
		interrupt_fade()


func _on_menu_closed():
	is_menu_blocking_fade = false
	_set_interaction_enabled(true)
	if not is_in_slot:
		attempt_fade_out()


func _set_interaction_enabled(enabled: bool):
	if col:
		col.input_pickable = enabled
	if not enabled and GameState.hovered_tile == self:
		GameState.clear_hovered_tile()


func _to_string() -> String:
	return "".join(group_values)


func get_slot_length() -> int:
	return group_values.size()


func get_slot_value(index: int) -> String:
	if index < 0 or index >= group_values.size():
		return Constants.EMPTY_TILE_VALUE
	return group_values[index]


func set_slot_gap(gap: float):
	slot_gap = gap
	_build_symbol_pattern()
	_update_thought_bubble_width()
	_update_interaction_bounds()


func get_drag_half_extents() -> Vector2:
	var tile_size = _get_base_tile_size()
	var width = tile_size.x + (max(0, get_slot_length() - 1) * slot_gap)
	return Vector2(width * 0.5, tile_size.y * 0.5)


func contains_global_point(point: Vector2) -> bool:
	if !collision_shape or !collision_shape.shape:
		return false
	var rect_shape := collision_shape.shape as RectangleShape2D
	if !rect_shape:
		return false
	var local_point = to_local(point) - collision_shape.position
	var half_size = rect_shape.size * 0.5
	return absf(local_point.x) <= half_size.x and absf(local_point.y) <= half_size.y


func get_group_center_offset() -> Vector2:
	var extra_width = max(0.0, float(get_slot_length() - 1) * slot_gap)
	return Vector2(extra_width * 0.5, 0)


func set_group_center_global_position(center_pos: Vector2):
	global_position = center_pos - get_group_center_offset()


func pickup():
	if is_in_slot:
		pickup_from_slot()
	else:
		pickup_from_field()


func place_in_field(return_to_field: bool = false):
	if return_to_field:
		global_position = last_field_global_position
	else:
		last_field_global_position = global_position
	emit_signal("placed_in_field")
	attempt_fade_out()


func pickup_from_field():
	last_field_global_position = global_position
	emit_signal("picked_up_from_field")
	interrupt_fade()


func place_in_slot():
	is_in_slot = true
	interrupt_fade()
	emit_signal("placed_in_slot")


func pickup_from_slot():
	is_in_slot = false
	emit_signal("picked_up_from_slot")
	interrupt_fade()


func _generate_group_values() -> Array[String]:
	var values: Array[String] = []
	var length = randi_range(Constants.MIN_VALUE_LENGTH, Constants.MAX_VALUE_LENGTH)
	for i in range(length):
		values.append(Constants.ALPHABET[randi_range(0, Constants.ALPHABET.length() - 1)])
	return values


func on_mouse_entered():
	if is_menu_blocking_fade:
		return
	GameState.set_hovered_tile(self)
	print('hovered: ', name)


func on_mouse_exited():
	if GameState.hovered_tile == self and GameState.current_tile != self:
		GameState.clear_hovered_tile()


func delete():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	queue_free()

extends Node2D

@onready var col = $Area2D

var snap: Node2D
var value: String = Constants.EMPTY_TILE_VALUE
var is_fading_out: bool = false
var fade_tween: Tween
signal placed_in_field
signal picked_up_from_field
signal placed_in_slot
signal picked_up_from_slot
signal faded_out
var is_in_slot: bool = false


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)

	value = _generate_value()

	#TODO: JUICE POINT
	modulate.a = 1.0

	attempt_fade_out()


func attempt_fade_out() -> void:
	if is_in_slot:
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


func _to_string() -> String:
	return value


func pickup():
	if is_in_slot:
		pickup_from_slot()
	else:
		pickup_from_field()


func place_in_field():
	emit_signal("placed_in_field")
	attempt_fade_out()


func pickup_from_field():
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


func delete():
	queue_free()

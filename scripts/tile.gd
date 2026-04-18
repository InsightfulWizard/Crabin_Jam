extends Node2D

@onready var col = $Area2D

var snap: Node2D
var value: String = Constants.EMPTY_TILE_VALUE
var is_fading_out: bool = false
var fade_tween: Tween
signal returned_to_field
signal placed_in_slot
signal picked_up


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)

	value = _generate_value()

	#TODO: JUICE POINT
	modulate.a = 1.0

	attempt_fade_out()


func attempt_fade_out() -> void:
	if GameState.current_tile == self:
		get_tree().create_timer(1.0).timeout.connect(attempt_fade_out)

	if not is_fading_out:
		is_fading_out = true

		var stay_time = randf_range(2.0, 4.0) # TODO: could make dependent on score?

		#TODO: JUICE POINT
		# Face outtween sequence:
		fade_tween = create_tween()
		fade_tween.tween_interval(stay_time)
		fade_tween.tween_property(self, "modulate:a", 0.0, 0.8)

		fade_tween.finished.connect(queue_free)


func interrupt_fade():
	is_fading_out = false
	if fade_tween and fade_tween.is_running():
		fade_tween.kill() # STOP the animation immediately

	#TODO: JUICE POINT
	modulate.a = 1.0 # Snap back to fully visible


func _to_string() -> String:
	return value


func drop_to_field():
	# print("Tile dropped back to field, will attempt fade out")
	emit_signal("returned_to_field")
	attempt_fade_out()


func place_in_slot():
	# print("Tile placed in slot!")
	emit_signal("placed_in_slot")


func pickup():
	# print("Tile picked up!")
	emit_signal("picked_up")
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

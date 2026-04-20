extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.connect('potential_score_changed', _on_potential_score_changed)
	_on_potential_score_changed(GameState.potential_score)


func _on_potential_score_changed(score: int):
	text = str(score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

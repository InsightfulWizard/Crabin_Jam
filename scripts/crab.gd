extends Node2D

@onready var sweat: CPUParticles2D = $sweat


func _ready() -> void:
	GameState.connect('score_changed', _on_score_changed)


func _on_score_changed(_score: int):
	if GameState.state == GameState.CHILLIN:
		toggle_chillin(true)
		toggle_stresed(false)
		toggle_dread(false)
	if GameState.state == GameState.STRESSED:
		toggle_chillin(false)
		toggle_stresed(true)
		toggle_dread(false)
	if GameState.state == GameState.DREAD:
		toggle_chillin(false)
		toggle_stresed(false)
		toggle_dread(true)


func toggle_chillin(b: bool):
	pass


func toggle_stresed(b: bool):
	pass


func toggle_dread(b: bool):
	sweat.emitting = b

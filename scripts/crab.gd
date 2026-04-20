extends Node2D

@onready var sweat: CPUParticles2D = $sweat

var moving_tween: Tween
var initial_pos: Vector2


func _ready() -> void:
	Util.crab = self
	GameState.connect('score_changed', _on_score_changed)
	_on_score_changed(GameState.current_score)

	GameState.connect('menu_opened', _on_menu_open)
	GameState.connect('menu_closed', _on_menu_closed)
	initial_pos = position

	position.y = get_viewport().get_visible_rect().size.y * 1.2

	#start_timer()


func _on_menu_open():
	var ypos: float = get_viewport().get_visible_rect().size.y * 1.2
	move(Vector2(initial_pos.x, ypos), 1.5)


func _on_menu_closed():
	move(initial_pos, 4.0)
	await moving_tween.finished
	var audio = AudioManager.play_sfx_from_array(AudioManager.throat_clear, 0.0)
	if audio:
		await audio.finished

	GameState.start_game()


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


func toggle_chillin(_b: bool):
	pass


func toggle_stresed(_b: bool):
	pass


func toggle_dread(b: bool):
	print('toggle_dread: ', b)
	sweat.emitting = b


func move(pos: Vector2, time: float):
	if moving_tween and moving_tween.is_valid():
		moving_tween.kill()
	moving_tween = get_tree().create_tween()
	moving_tween.set_trans(Tween.TRANS_QUAD)
	moving_tween.set_ease(Tween.EASE_OUT)
	moving_tween.tween_property(self, 'position', pos, time)

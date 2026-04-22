extends Node2D

@onready var sweat: CPUParticles2D = $sweat
@onready var plate: Sprite2D = $plate
@onready var lemon: Sprite2D = $lemon
@onready var boiling_pot: Node2D = $"boiling pot"
var boiling_pot_pos_init: Vector2

var moving_tween: Tween
var initial_pos: Vector2
var game_lost := false


func _ready() -> void:
	Util.crab = self
	GameState.connect('score_changed', _on_score_changed)
	_on_score_changed(GameState.current_score)

	GameState.connect('menu_opened', _on_menu_open)
	GameState.connect('menu_closed', _on_menu_closed)
	GameState.connect('game_lost', _on_game_lost)
	GameState.connect('game_reset', _on_game_reset)
	initial_pos = position

	position.y = get_viewport().get_visible_rect().size.y * 1.2
	
	plate.visible = false
	lemon.visible = false
	boiling_pot_pos_init = boiling_pot.position

	#start_timer()


func _on_menu_open():
	if Util.menu.current_menu == Util.menu.WIN or Util.menu.current_menu == Util.menu.LOSE:
		return
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
	if game_lost:
		return
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
	print('QQQ toggle_dread:  ', b)
	print('QQQ toggle_dread game_lost:  ', game_lost)
	if game_lost:
		sweat.emitting = false
		return
	print('toggle_dread: ', b)
	sweat.emitting = b


func move(pos: Vector2, time: float):
	if moving_tween and moving_tween.is_valid():
		moving_tween.kill()
	moving_tween = get_tree().create_tween()
	moving_tween.set_trans(Tween.TRANS_QUAD)
	moving_tween.set_ease(Tween.EASE_OUT)
	moving_tween.tween_property(self, 'position', pos, time)
	
	
func _on_game_lost():
	var pot_tween = create_tween()
	pot_tween.set_trans(Tween.TRANS_QUAD)
	pot_tween.set_ease(Tween.EASE_OUT)
	pot_tween.tween_property(boiling_pot, "position", Vector2.ZERO, 1.5)
	
	await pot_tween.finished
	
	game_lost = true
	GameState.emit_signal('crab_boiled')
	sweat.emitting = false
	
	pot_tween = create_tween()
	pot_tween.set_ease(Tween.EASE_IN_OUT)
	pot_tween.chain().tween_property(boiling_pot, "rotation", .125, .125)
	pot_tween.chain().tween_property(boiling_pot, "rotation", -.125, .125)
	pot_tween.chain().tween_property(boiling_pot, "rotation", .125, .125)
	pot_tween.chain().tween_property(boiling_pot, "rotation", -.125, .125)
	pot_tween.chain().tween_property(boiling_pot, "rotation", 0.0, .125)
	
	pot_tween.chain().tween_property(boiling_pot, "position", boiling_pot_pos_init, 1.5)
	
	await pot_tween.finished
	
	plate.visible = true
	lemon.visible = true
	plate.scale = Vector2.ZERO
	lemon.scale = Vector2.ZERO
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(plate, "scale", Vector2(1,1), .5)
	tween.parallel().tween_property(lemon, "scale", Vector2(1,1), .5)


func _on_game_reset():
	game_lost = false
	print('QQQ _on_game_reset:  ', game_lost)
	plate.scale = Vector2.ONE
	lemon.scale = Vector2.ONE
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(plate, "scale", Vector2(0,0), .5)
	tween.parallel().tween_property(lemon, "scale", Vector2(0,0), .5)
	await tween.finished
	plate.visible = false
	lemon.visible = false
	_on_menu_open()

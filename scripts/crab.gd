extends Node2D

@onready var sweat: CPUParticles2D = $sweat
@onready var plate: Sprite2D = $plate
@onready var lemon: Sprite2D = $lemon
@onready var boiling_pot: Node2D = $"boiling pot"
@onready var sunglasses: Node2D = $sunglasses

var current_state: int = 2

var boiling_pot_pos_init: Vector2

var moving_tween: Tween
var initial_pos: Vector2
var game_lost := false
var sunglasses_pos_init: Vector2
var sunglasses_tween: Tween
var end_sequence_tween: Tween


func _ready() -> void:
	Util.crab = self
	GameState.connect('state_changed', _on_state_changed)
	_on_state_changed(GameState.state)
	#toggle_dread(true)
	GameState.connect('menu_opened', _on_menu_open)
	GameState.connect('menu_closed', _on_menu_closed)
	GameState.connect('game_lost', _on_game_lost)
	GameState.connect('game_reset', _on_game_reset)
	initial_pos = position
	position.y = get_viewport().get_visible_rect().size.y * 1.2
	
	plate.visible = false
	lemon.visible = false
	boiling_pot_pos_init = boiling_pot.position
	sunglasses.visible = false
	sunglasses_pos_init = sunglasses.position
	var far_pos := Vector2( sunglasses_pos_init.x, -get_viewport().get_visible_rect().size.y * 1.2 )
	sunglasses.position = far_pos
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


func _on_state_changed(state: int):
	if game_lost:
		return
	if current_state == GameState.CHILLIN:
		toggle_chillin(false)
	elif current_state == GameState.STRESSED:
		toggle_stressed(false)
	elif current_state == GameState.DREAD:
		toggle_dread(false)

	if state == GameState.CHILLIN:
		toggle_chillin(true)
	elif state == GameState.STRESSED:
		toggle_stressed(true)
	elif state == GameState.DREAD:
		toggle_dread(true)
	
	current_state = state


func toggle_chillin(b: bool):
	var far_pos := Vector2( sunglasses_pos_init.x, -get_viewport().get_visible_rect().size.y * 1.2 )
	if b:
		if sunglasses_tween and sunglasses_tween.is_valid():
			sunglasses_tween.kill()
		sunglasses.visible = true
		sunglasses_tween = create_tween()
		sunglasses_tween.tween_property(sunglasses, 'position', sunglasses_pos_init, 4.0)
	else:
		if sunglasses_tween and sunglasses_tween.is_valid():
			sunglasses_tween.kill()
		sunglasses.visible = true
		sunglasses_tween = create_tween()
		sunglasses_tween.tween_property(sunglasses, 'position', far_pos, 4.0)
		await sunglasses_tween.finished
		sunglasses.visible = false


func toggle_stressed(_b: bool):
	pass


func toggle_dread(b: bool):
	if game_lost:
		sweat.emitting = false
		return
	sweat.emitting = b


func move(pos: Vector2, time: float):
	if moving_tween and moving_tween.is_valid():
		moving_tween.kill()
	moving_tween = get_tree().create_tween()
	moving_tween.set_trans(Tween.TRANS_QUAD)
	moving_tween.set_ease(Tween.EASE_OUT)
	moving_tween.tween_property(self, 'position', pos, time)
	
	
func _on_game_lost():
	kill_end_sequence_tween()
	boiling_pot.visible = true
	end_sequence_tween = create_tween()
	end_sequence_tween.set_trans(Tween.TRANS_QUAD)
	end_sequence_tween.set_ease(Tween.EASE_OUT)
	end_sequence_tween.tween_property(boiling_pot, "position", Vector2.ZERO, 1.5)
	
	await end_sequence_tween.finished
	
	game_lost = true
	GameState.emit_signal('crab_boiled')
	sweat.emitting = false
	
	end_sequence_tween = create_tween()
	end_sequence_tween.set_ease(Tween.EASE_IN_OUT)
	end_sequence_tween.chain().tween_property(boiling_pot, "rotation", .125, .125)
	end_sequence_tween.chain().tween_property(boiling_pot, "rotation", -.125, .125)
	end_sequence_tween.chain().tween_property(boiling_pot, "rotation", .125, .125)
	end_sequence_tween.chain().tween_property(boiling_pot, "rotation", -.125, .125)
	end_sequence_tween.chain().tween_property(boiling_pot, "rotation", 0.0, .125)
	
	end_sequence_tween.chain().tween_property(boiling_pot, "position", boiling_pot_pos_init, 1.5)
	
	await end_sequence_tween.finished
	
	plate.visible = true
	lemon.visible = true
	plate.scale = Vector2.ZERO
	lemon.scale = Vector2.ZERO
	end_sequence_tween = create_tween()
	end_sequence_tween.set_trans(Tween.TRANS_QUAD)
	end_sequence_tween.set_ease(Tween.EASE_IN_OUT)
	end_sequence_tween.tween_property(plate, "scale", Vector2(1,1), .5)
	end_sequence_tween.parallel().tween_property(lemon, "scale", Vector2(1,1), .5)


func kill_end_sequence_tween():
	if end_sequence_tween and end_sequence_tween.is_valid():
		end_sequence_tween.kill()


func _on_game_reset():
	kill_end_sequence_tween()
	game_lost = false
	end_sequence_tween = create_tween()
	end_sequence_tween.set_trans(Tween.TRANS_QUAD)
	end_sequence_tween.set_ease(Tween.EASE_IN_OUT)
	end_sequence_tween.tween_property(plate, "scale", Vector2(0,0), .5)
	end_sequence_tween.parallel().tween_property(lemon, "scale", Vector2(0,0), .5)
	end_sequence_tween.parallel().tween_property(boiling_pot, "position", boiling_pot_pos_init, .5)
	end_sequence_tween.parallel().tween_property(boiling_pot, "rotation", 0.0, .5)
	await end_sequence_tween.finished
	plate.visible = false
	lemon.visible = false
	boiling_pot.visible = false
	_on_menu_open()

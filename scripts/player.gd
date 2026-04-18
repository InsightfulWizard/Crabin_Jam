extends Node2D

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("select"):
		pass
	if Input.is_action_just_released("select"):
		drop_tile()


func _input(event):
	if event.is_action_pressed("select"):
		if GameState.hovered_tile:
			pickup_tile(GameState.hovered_tile)
	if event is InputEventMouseMotion:
		if GameState.current_tile:
			GameState.current_tile.position = event.position


func pickup_tile(tile: Node2D):
	GameState.current_tile = tile
	if tile.snap:
		tile.snap.unsnap()
	tile.position = get_viewport().get_mouse_position()


func drop_tile():
	var tile = GameState.current_tile
	if !tile:
		return
	var snap = Util.get_closest(tile.global_position, 'tile_snap', 130.0)
	#var snap = GameState.hovered_snap
	if snap:
		snap.to_snap(tile)
		# var vals = Util.hud.get_output_values()
		# print("vals: ", vals)
		Util.hud.score_solution()

	GameState.current_tile = null

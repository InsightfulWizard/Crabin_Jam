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
			#tile to mouse, clamped to viewport
			var size: Vector2 = get_viewport().get_visible_rect().size
			var pos: Vector2 = event.position
			pos = Vector2(clampf(pos.x, 0, size.x), clampf(pos.y, 0, size.y))
			GameState.current_tile.position = pos
			#shuffle other tiles
			
			
	if event.is_action_pressed("test"):
		Util.hud.submit_output_trays()
	if event.is_action_pressed("escape"):
		get_tree().quit()


func pickup_tile(tile: Node2D):
	GameState.current_tile = tile
	tile.pickup()
	if tile.snap:
		tile.snap.unsnap()
	tile.position = get_viewport().get_mouse_position()


func drop_tile():
	var tile = GameState.current_tile
	if !tile:
		return
	var snap = Util.get_closest(tile.global_position, 'tile_snap', 65.0)

	if snap and snap.to_snap(tile):
		tile.place_in_slot()
	else:
		var attempted_occupied_snap = snap != null
		if attempted_occupied_snap:
			tile.place_in_field(true)
		else:
			tile.place_in_field()

		if GameState.hovered_tile == tile:
			tile.scale = Vector2.ONE
			GameState.clear_hovered_tile()
	GameState.current_tile = null


func delete():
	queue_free()
	#TODO: JUICE POINT

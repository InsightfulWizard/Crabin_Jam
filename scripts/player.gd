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
			var extents = Vector2.ZERO
			if GameState.current_tile.has_method("get_drag_half_extents"):
				extents = GameState.current_tile.get_drag_half_extents()
			pos = Vector2(
				clampf(pos.x, extents.x, size.x - extents.x),
				clampf(pos.y, extents.y, size.y - extents.y),
			)
			if GameState.current_tile.has_method("set_group_center_global_position"):
				GameState.current_tile.set_group_center_global_position(pos)
			else:
				GameState.current_tile.global_position = pos
	if event.is_action_pressed("test"):
		Util.hud.submit_output_trays()
	if event.is_action_pressed("t1"):
		GameState.set_current_score(70)
	if event.is_action_pressed("t2"):
		GameState.set_current_score(-50)
		


func pickup_tile(tile: Node2D):
	GameState.current_tile = tile
	tile.pickup()
	if tile.snap:
		tile.snap.unsnap()
	var mouse_pos = get_viewport().get_mouse_position()
	if tile.has_method("set_group_center_global_position"):
		tile.set_group_center_global_position(mouse_pos)
	else:
		tile.global_position = mouse_pos


func drop_tile():
	var tile = GameState.current_tile
	if !tile:
		return
	var snap = _get_nearest_valid_snap(tile, 65.0)
	var nearest_any_snap = Util.get_closest(tile.global_position, 'tile_snap', 65.0)

	if snap and snap.to_snap(tile):
		tile.place_in_slot()
	else:
		var attempted_occupied_snap = nearest_any_snap != null
		if attempted_occupied_snap:
			tile.place_in_field(true)
		else:
			tile.place_in_field()

		if GameState.hovered_tile == tile:
			tile.scale = Vector2.ONE
			GameState.clear_hovered_tile()
	GameState.current_tile = null


func _get_nearest_valid_snap(tile: Node2D, thresh: float) -> Node2D:
	var closest_d: float = INF
	var closest: Node2D
	for n in get_tree().get_nodes_in_group("tile_snap"):
		if !n.active:
			continue
		if !n.can_snap_tile(tile):
			continue
		var d := tile.global_position.distance_to(n.global_position)
		if d < closest_d:
			closest_d = d
			closest = n
	if closest_d < thresh:
		return closest
	return null


func delete():
	queue_free()
	#TODO: JUICE POINT

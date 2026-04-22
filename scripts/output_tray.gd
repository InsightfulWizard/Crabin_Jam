extends Node2D

var _cached_snaps: Array[Node2D] = []


func _ready() -> void:
	refresh_snap_cache()


func refresh_snap_cache() -> void:
	_cached_snaps.clear()
	for n in get_children():
		if n.is_in_group('tile_snap'):
			_cached_snaps.append(n)
	_cached_snaps.sort_custom(func(a: Node2D, b: Node2D): return a.position.x < b.position.x)
	for i in range(_cached_snaps.size()):
		_cached_snaps[i].slot_index = i


func get_sorted_snaps() -> Array[Node2D]:
	if _cached_snaps.is_empty():
		refresh_snap_cache()
	return _cached_snaps


func get_slot_gap() -> float:
	var snaps = get_sorted_snaps()
	if snaps.size() < 2:
		return 72.0
	return absf(snaps[1].global_position.x - snaps[0].global_position.x)


func can_place_at(start_index: int, tile: Node2D) -> bool:
	var snaps = get_sorted_snaps()
	if start_index < 0 or start_index >= snaps.size():
		return false
	var slot_length = tile.get_slot_length()
	if slot_length <= 0:
		return false
	if start_index + slot_length > snaps.size():
		return false
	for i in range(slot_length):
		if snaps[start_index + i].snapped_tile:
			return false
	return true


func place_at(start_snap: Node2D, tile: Node2D) -> bool:
	if !start_snap.active:
		return false
	if !can_place_at(start_snap.slot_index, tile):
		return false

	var slot_length = tile.get_slot_length()
	var snaps = get_sorted_snaps()
	tile.set_slot_gap(get_slot_gap())

	tile.get_parent().remove_child(tile)
	start_snap.add_child(tile)
	tile.position = Vector2.ZERO
	tile.snap = start_snap

	for i in range(slot_length):
		var snap = snaps[start_snap.slot_index + i]
		snap.snapped_tile = tile
		snap.snapped_index = i

	return true


func unsnap_tile(tile: Node2D):
	if !tile:
		return
	for snap in get_sorted_snaps():
		if snap.snapped_tile == tile:
			snap.snapped_tile = null
			snap.snapped_index = -1
	Util.hud.to_hud_space(tile)
	tile.snap = null


func get_output_values():
	var output_values: Array[String] = []
	for n in get_sorted_snaps():
		if !n.snapped_tile:
			output_values.append(Constants.EMPTY_TILE_VALUE)
			continue
		output_values.append(n.snapped_tile.get_slot_value(n.snapped_index))
	return output_values


func reset():
	var handled: Dictionary = { }
	for n in get_sorted_snaps():
		n.assign_rand_filler_word()
		n.assign_rand_blank_penalty()
		if !n.snapped_tile:
			continue
		if handled.has(n.snapped_tile):
			continue
		handled[n.snapped_tile] = true
		n.delete_tile()


func set_snaps_active(b: bool):
	for n in get_sorted_snaps():
		n.active = b


func get_blank_penalty() -> int:
	var penalty:int = 0
	for n in get_sorted_snaps():
		if !n.snapped_tile:
			penalty += n.blank_penalty
	return penalty

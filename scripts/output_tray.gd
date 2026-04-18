extends Node2D


func get_output_values():
	var vals: Array[String] = []
	for n in get_children():
		if !n.is_in_group('tile_snap'):
			continue
		if !n.snapped_tile:
			vals.append(Constants.EMPTY_TILE_VALUE)
			continue
		vals.append(n.snapped_tile.to_string())
	return vals


func reset():
	for n in get_children():
		if !n.is_in_group('tile_snap'):
			continue
		if n.snapped_tile:
			n.delete_tile()


func set_snaps_active(b:bool):
	var vals: Array[String] = []
	for n in get_children():
		if !n.is_in_group('tile_snap'):
			continue
		n.active = b

extends Node2D


func get_output_values():
	var vals:Array[int] = []
	for n in get_children():
	#for n in output_tray_1.get_children():
		if !n.is_in_group('tile_snap'):
			continue
		if !n.snapped_tile:
			vals.append(-1)
			continue
		vals.append(n.snapped_tile.value)
	return vals


func reset():
	for n in get_children():
		if !n.is_in_group('tile_snap'):
			continue
		if n.snapped_tile:
			n.delete_tile()

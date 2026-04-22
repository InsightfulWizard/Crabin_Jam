extends Node2D

@export var tile_scene: PackedScene
@export var max_tiles: int = 3
@export var polling_interval: float = 0.25
@export var border_buffer: float = 10.0

var current_tile_count: int = 0
var tile_size = Vector2.ZERO
var spawn_timer: Timer
var is_spawning_enabled: bool = true


func _ready():
	# Seed a fallback tile footprint from the tile scene's UI/control size.
	var temp_tile = tile_scene.instantiate()
	var thought_ui = temp_tile.get_node_or_null("fancier_ui")
	if thought_ui is Control:
		tile_size = thought_ui.size * thought_ui.scale.abs()
	else:
		for child in temp_tile.get_children():
			if child is Sprite2D and child.texture:
				# Legacy fallback for older tile scenes.
				tile_size = child.texture.get_size() * child.scale.abs()
				break
	temp_tile.queue_free()

	# Start the spawn loop
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = polling_interval #how often to check for spawning a new tile
	spawn_timer.timeout.connect(_on_timer_timeout)
	spawn_timer.start()

	if GameState and GameState.has_signal("menu_opened") and GameState.has_signal("menu_closed"):
		GameState.menu_opened.connect(_on_menu_opened)
		GameState.menu_closed.connect(_on_menu_closed)
		set_spawning_enabled(not GameState.is_menu_open)


# Create a helper to handle all the signal connections in one place
func _register_tile(tile):
	current_tile_count += 1 # Count this new tile

	tile.faded_out.connect(_on_tile_removed)
	tile.picked_up_from_field.connect(_on_tile_removed)
	tile.placed_in_field.connect(_on_tile_returned)


func _on_tile_removed():
	current_tile_count = max(0, current_tile_count - 1)


func _on_tile_returned():
	current_tile_count += 1


func _on_timer_timeout():
	check_and_spawn_tile()


func set_spawning_enabled(enabled: bool):
	is_spawning_enabled = enabled
	if spawn_timer == null:
		return

	if is_spawning_enabled:
		spawn_timer.start()
		check_and_spawn_tile()
	else:
		spawn_timer.stop()
		for t in get_tree().get_nodes_in_group('spawned_tiles'):
			if !t.snap:
				t.delete()
		current_tile_count = 0
		


func _on_menu_opened():
	set_spawning_enabled(false)


func _on_menu_closed():
	set_spawning_enabled(true)


func check_and_spawn_tile():
	if not is_spawning_enabled:
		return
	if current_tile_count < max_tiles:
		var tile = tile_scene.instantiate()
		var candidate_extents = _get_tile_half_extents(tile)
		var center_pos = find_valid_pos(candidate_extents)
		if center_pos != Vector2.INF:
			spawn_tile(tile, center_pos)
		else:
			tile.queue_free()


func find_valid_pos(candidate_extents: Vector2) -> Vector2:
	var view_rect = get_viewport_rect()
	var shape_node = $CollisionShape2D
	var rx = (shape_node.shape.radius * shape_node.scale.x)
	var ry = (shape_node.shape.radius * shape_node.scale.y)

	# Margin to keep full tile footprint on screen with added buffer.
	var margin = candidate_extents + Vector2(border_buffer, border_buffer)

	for attempt in range(15): # Try 15 times to find a gap
		var theta = randf() * 2 * PI
		var r = sqrt(randf())
		var candidate_center = global_position + Vector2(r * rx * cos(theta), r * ry * sin(theta))

		# keep on screen
		candidate_center.x = clamp(
			candidate_center.x,
			view_rect.position.x + margin.x,
			view_rect.end.x - margin.x,
		)
		candidate_center.y = clamp(
			candidate_center.y,
			view_rect.position.y + margin.y,
			view_rect.end.y - margin.y,
		)

		# Check if another spawned field tile already occupies this footprint.
		if is_spot_clear(candidate_center, candidate_extents):
			return candidate_center
	return Vector2.INF


func is_spot_clear(candidate_center: Vector2, candidate_extents: Vector2) -> bool:
	for node in get_tree().get_nodes_in_group("spawned_tiles"):
		if _is_tile_in_slot(node):
			continue
		var center_delta = candidate_center - _get_tile_center(node)
		var node_extents = _get_tile_half_extents(node)
		var overlaps_x = absf(center_delta.x) < (candidate_extents.x + node_extents.x)
		var overlaps_y = absf(center_delta.y) < (candidate_extents.y + node_extents.y)
		if overlaps_x and overlaps_y:
			return false
	return true


func spawn_tile(tile: Node2D, center_pos: Vector2):
	# Add tile to a group so we can find it for the overlap check
	tile.add_to_group("spawned_tiles")
	get_parent().add_child.call_deferred(tile)
	if tile.has_method("set_group_center_global_position"):
		tile.set_group_center_global_position(center_pos)
	else:
		tile.global_position = center_pos
	_register_tile(tile) # Connect signals to track this tile


func _get_tile_half_extents(tile: Node2D) -> Vector2:
	if tile.has_method("get_drag_half_extents"):
		return tile.get_drag_half_extents()

	var slot_length = 1
	if tile.has_method("get_slot_length"):
		slot_length = max(1, tile.get_slot_length())
	var slot_gap = 72.0
	var node_gap = tile.get("slot_gap")
	if typeof(node_gap) in [TYPE_FLOAT, TYPE_INT]:
		slot_gap = float(node_gap)

	var base_size = tile_size
	var tile_thought = tile.get_node_or_null("fancier_ui")
	if tile_thought is Control:
		base_size = tile_thought.size * tile_thought.scale.abs()

	var width = base_size.x + (float(slot_length - 1) * slot_gap)
	return Vector2(width * 0.5, base_size.y * 0.5)


func _get_tile_center(tile: Node2D) -> Vector2:
	if tile.has_method("get_group_center_offset"):
		return tile.global_position + tile.get_group_center_offset()
	return tile.global_position


func _is_tile_in_slot(tile: Node2D) -> bool:
	var in_slot = tile.get("is_in_slot")
	return typeof(in_slot) == TYPE_BOOL and in_slot

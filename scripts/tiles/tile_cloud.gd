extends Node2D

@export var tile_scene: PackedScene
@export var max_tiles: int = 3
@export var polling_interval: float = 0.25
@export var border_buffer: float = 10.0

var current_tile_count: int = 0
var tile_size = Vector2.ZERO


func _ready():
	#Get the size of the SVG from the scene
	var temp_tile = tile_scene.instantiate()
	for child in temp_tile.get_children():
		if child is Sprite2D and child.texture:
			tile_size = child.texture.get_size()
			break
	temp_tile.queue_free()

	# Start the spawn loop
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = polling_interval #how often to check for spawning a new tile
	timer.timeout.connect(_on_timer_timeout)
	timer.start()


# Create a helper to handle all the signal connections in one place
func _register_tile(tile):
	current_tile_count += 1 # Count this new tile

	# If it leaves (fades or slots), count goes down
	#dont need to check if placed in slot since we already decremented on pick up
	tile.tree_exited.connect(_on_tile_removed)
	tile.picked_up.connect(_on_tile_removed)
	tile.placed_in_slot.connect(_on_tile_returned) #TODO: this seems wrong, check after update
	tile.returned_to_field.connect(_on_tile_returned)


func _on_tile_removed():
	print("Active tiles: ", current_tile_count)
	current_tile_count = max(0, current_tile_count - 1)


func _on_tile_returned():
	print("Active tiles: ", current_tile_count)
	current_tile_count += 1


func _on_timer_timeout():
	check_and_spawn_tile()


func check_and_spawn_tile():
	if current_tile_count < max_tiles:
		var pos = find_valid_pos()
		if pos != Vector2.INF:
			spawn_tile(pos)


func find_valid_pos() -> Vector2:
	var view_rect = get_viewport_rect()
	var shape_node = $CollisionShape2D
	var rx = (shape_node.shape.radius * shape_node.scale.x)
	var ry = (shape_node.shape.radius * shape_node.scale.y)

	# Margin to keep the SVG fully on screen w/ added buffer
	var margin = tile_size / 2.0 + Vector2(border_buffer, border_buffer)

	for attempt in range(15): # Try 15 times to find a gap
		var theta = randf() * 2 * PI
		var r = sqrt(randf())
		var candidate = global_position + Vector2(r * rx * cos(theta), r * ry * sin(theta))

		# keep on screen
		candidate.x = clamp(
			candidate.x,
			view_rect.position.x + margin.x,
			view_rect.end.x - margin.x,
		)
		candidate.y = clamp(
			candidate.y,
			view_rect.position.y + margin.y,
			view_rect.end.y - margin.y,
		)

		# Check if another tile is already at this global position
		if is_spot_clear(candidate):
			return candidate
	return Vector2.INF


func is_spot_clear(pos: Vector2) -> bool:
	# Simple distance check against existing tiles
	for node in get_tree().get_nodes_in_group("spawned_tiles"):
		if pos.distance_to(node.global_position) < tile_size.x: # Use width as threshold
			return false
	return true


func spawn_tile(pos: Vector2):
	var tile = tile_scene.instantiate()
	# Add tile to a group so we can find it for the overlap check
	tile.add_to_group("spawned_tiles")
	get_parent().add_child.call_deferred(tile)
	tile.global_position = pos
	_register_tile(tile) # Connect signals to track this tile

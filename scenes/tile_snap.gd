extends Node2D

@onready var col = $Area2D

var snapped_tile: Node2D
var active: bool = true


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)


func on_mouse_entered():
	GameState.hovered_snap = self


func on_mouse_exited():
	if GameState.hovered_snap == self:
		GameState.hovered_snap = null


func to_snap(tile: Node2D) -> bool:
	if snapped_tile:
		return false
	tile.get_parent().remove_child(tile)
	add_child(tile)
	tile.position = Vector2.ZERO
	#tile.global_position = global_position
	#tile.global_position.y -= 100
	tile.snap = self
	snapped_tile = tile
	return true


func unsnap():
	if !snapped_tile:
		return
	Util.hud.to_hud_space(snapped_tile)
	snapped_tile.snap = null
	snapped_tile = null


func delete_tile():
	if !snapped_tile:
		return
	snapped_tile.delete()
	snapped_tile = null

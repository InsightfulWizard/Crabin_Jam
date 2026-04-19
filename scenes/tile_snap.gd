extends Node2D

@onready var col = $Area2D

var snapped_tile: Node2D
var snapped_index: int = -1
var slot_index: int = -1
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
	if !active:
		return false
	return get_parent().place_at(self, tile)


func can_snap_tile(tile: Node2D) -> bool:
	if !active:
		return false
	return get_parent().can_place_at(slot_index, tile)


func unsnap():
	if !snapped_tile:
		return
	get_parent().unsnap_tile(snapped_tile)


func delete_tile():
	if !snapped_tile:
		return
	var tile = snapped_tile
	get_parent().unsnap_tile(tile)
	tile.delete()

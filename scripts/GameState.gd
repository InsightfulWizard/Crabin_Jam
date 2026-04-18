extends Node2D

var hovered_tile = null
var current_tile = null

var hovered_snap = null
var current_snap = null


func set_hovered_tile(tile:Node2D):
	if hovered_tile == tile:
		return
	if hovered_tile:
		hovered_tile.scale = Vector2.ONE
	tile.scale = Vector2.ONE * 1.2
	hovered_tile = tile


func clear_hovered_tile():
	hovered_tile = null
	

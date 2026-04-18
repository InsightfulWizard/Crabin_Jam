extends Node

var hud: CanvasLayer
#var speaker: CanvasLayer
#var crowd: CanvasLayer


func get_closest(p:Vector2, g:String, thresh: float = 20.0):
	var closest_d: float = INF
	var closest: Node2D
	for n in get_tree().get_nodes_in_group(g):
		var d := p.distance_to(n.global_position)
		if d < closest_d:
			closest_d = d
			closest = n
	if closest_d < thresh:
		return closest
		

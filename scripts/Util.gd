extends Node

var hud: CanvasLayer
var crab: Node2D
var menu
#var speaker: CanvasLayer
#var crowd: CanvasLayer


func get_closest(p:Vector2, g:String, thresh: float = 20.0):
	var closest_d: float = INF
	var closest: Node2D
	for n in get_tree().get_nodes_in_group(g):
		if !n.active:
			continue
		var d := p.distance_to(n.global_position)
		if d < closest_d:
			closest_d = d
			closest = n
	if closest_d < thresh:
		return closest
		

func tween_2d(obj:Node2D, param:String, target:Vector2, time:float = .6):
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(obj, param, target, time)
	return tween

extends Node2D
@onready var label: Label = $Label

var tween

var pos_initial: Vector2

func _ready() -> void:
	scale = Vector2.ZERO
	pos_initial = position
	position = Vector2(pos_initial.x, pos_initial.y + 30.0)


func go(i:int = 0):
	var t: String = ''
	if i > -0:
		t = '+'
	label.text = t + str(i)
	#modulate.a = 0
	if i < 1:
		label.add_theme_color_override( "font_color", Color(0.75, 0.11, 0.22) )
		label.add_theme_color_override( "font_outline_color", Color(0.448, 0.038, 0.159, 1.0) )
	else:
		label.add_theme_color_override( "font_color", Color(0.578, 0.608, 0.218, 1.0) )
		label.add_theme_color_override( "font_outline_color", Color(0.344, 0.345, 0.056, 1.0) )
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'scale', Vector2.ONE, 2.0)
	tween.parallel().tween_property(self, "position", pos_initial, 2.0)
	await tween.finished
	tween = create_tween()
	tween.set_ease(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", Vector2.ONE *.001, .5)
	await tween.finished
	position = Vector2(pos_initial.x, pos_initial.y + 30.0)
	scale = Vector2.ZERO

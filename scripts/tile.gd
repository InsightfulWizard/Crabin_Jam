extends Node2D

@onready var col = $Area2D

var snap: Node2D
var value: int = 0


func _ready():
	col.connect('mouse_entered', on_mouse_entered)
	col.connect('mouse_exited', on_mouse_exited)
	
	value = randi_range(0,9)


func on_mouse_entered():
	GameState.set_hovered_tile(self)


func on_mouse_exited():
	if GameState.hovered_tile == self:
		GameState.clear_hovered_tile()
		scale = Vector2.ONE


func delete():
	queue_free()
	#toto add shrinking juice

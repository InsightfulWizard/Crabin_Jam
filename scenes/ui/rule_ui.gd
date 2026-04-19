extends Control

@onready var pattern_layer = $PatternLayer

const SYMBOL_BASE_SCALE := Vector2(0.095, 0.095)

var image_map = {
	"△": preload("res://art/tiles/triangle.png"),
	"○": preload("res://art/tiles/circle.png"),
	"□": preload("res://art/tiles/square.png"),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

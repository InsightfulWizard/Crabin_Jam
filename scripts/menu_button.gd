extends Node2D

@onready var button: Button = $Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)


func _on_pressed():
	if Util.menu.current_menu == Util.menu.WIN or Util.menu.current_menu == Util.menu.LOSE:
		return
	GameState.toggle_menu(true)

extends CanvasLayer

@export var main_menu: Control
@export var settings: Control
var menus: Array = []


#----Main Menu
@export var m_play: Button
@export var m_settings: Button
@export var m_exit: Button


#----Settings
@export var s_main_menu: Button
@export var s_resolution: Button
var high_res := true
@export var s_mouse_sensitivity: HSlider
@export var b_reset_mouse_sensitivity: Button
var mouse_sensitivity_default: float

var current_menu:int = MAIN_MENU

enum {
	MAIN_MENU,
	SETTINGS
}



func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	menus.append(main_menu)
	main_menu.visible = true
	menus.append(settings)
	settings.visible = false
	
	visible = GameState.is_menu_open
	GameState.connect('menu_opened', _on_menu_opened)
	GameState.connect('menu_closed', _on_menu_closed)
	
	m_play.connect('pressed', _resume)
	m_settings.connect('pressed', _open_settings)
	m_exit.connect('pressed', _exit_game)
	
	s_main_menu.connect('pressed', _open_main_menu)
	#s_resolution.connect('pressed', _toggle_resolution)
	#s_mouse_sensitivity.connect('drag_ended', _on_mouse_sens_change)
	#b_reset_mouse_sensitivity.connect('pressed', _reset_mouse_sensitivity)
	
	#mouse_sensitivity_default = Util.player.mouse_sense
	#s_mouse_sensitivity.value = mouse_sensitivity_default
	


func _on_menu_opened():
	visible = true
	
func _on_menu_closed():
	visible = false
	switch_to_menu(MAIN_MENU)


func _resume():
	GameState.toggle_menu_open()

func _open_settings():
	switch_to_menu(SETTINGS)

func _exit_game():
	GameState.exit_game()

func _open_main_menu():
	switch_to_menu(MAIN_MENU)

#func _toggle_resolution():
	#high_res = !high_res
	#if high_res:
		#get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
		#s_resolution.text = 'Resolution: Window'
	#else:
		#get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		#s_resolution.text = 'Resolution: Low'

#func _on_mouse_sens_change(b:bool):
	#if b:
		#var val: float = s_mouse_sensitivity.value
		#Util.player.mouse_sense = val
#
#func _reset_mouse_sensitivity():
	#s_mouse_sensitivity.value = mouse_sensitivity_default
	#Util.player.mouse_sense = mouse_sensitivity_default


func switch_to_menu(menu: int):
	if current_menu == menu:
		return
	menus[current_menu].visible = false
	menus[menu].visible = true
	current_menu = menu
	


#	if event.is_action_pressed("one"):
#		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
#
#	if event.is_action_pressed("two"):
#		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		
#	if event.is_action_pressed("plus"):
#		mouse_sense += .02
#
#	if event.is_action_pressed("minus"):
#		get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
#		mouse_sense -= .02

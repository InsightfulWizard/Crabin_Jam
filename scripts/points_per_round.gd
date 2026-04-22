extends Node2D

@onready var point_text: Label = $point_text
@onready var points: Label = $points

var points_per_round: int = 0


func _ready() -> void:
	GameState.connect('game_lost', set_points)
	GameState.connect('game_won', set_points)


func set_points():
	var str_sign := ''
	if GameState.points_won > 0:
		str_sign = '+'
	points_per_round = roundi( float(GameState.points_won) / float(GameState.rounds_played) )
	points.text = str_sign + str(points_per_round)
	
	point_text.text = get_text()
	if points_per_round < 1:
		point_text.add_theme_color_override( "font_color", Color(0.955, 0.22, 0.318, 1.0) )
		points.add_theme_color_override( "font_color", Color(0.955, 0.22, 0.318, 1.0) )
	else:
		point_text.add_theme_color_override( "font_color", Color(0x73cd8cff) )
		points.add_theme_color_override( "font_color", Color(0x73cd8cff) )


func get_text() -> String:
	if points_per_round < -60:
		return 'Not Quite!'
	elif points_per_round < -30:
		return 'They didn\'t like that!'
	elif points_per_round < 0:
		return 'No compromise reached!'
	elif points_per_round < 30:
		return 'Slowly but surely!'
	elif points_per_round < 60:
		return 'They came around!'
	elif points_per_round < 80:
		return 'Very Persuasive!'
	elif points_per_round < 90:
		return 'They love you!'
	elif points_per_round < 100:
		return 'You had them in your claw!'
	else:
		return 'Speech-craft over 1,000,000'
		
		
	

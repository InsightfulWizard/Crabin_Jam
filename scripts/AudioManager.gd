extends Node2D

#3D, once
var spatial_one_shots: Array[AudioStreamPlayer3D] = []
var max_spatial_one_shots: int = 20
@onready var sfxs = [
	dread,
	stressed,
	chillin
]

@onready var item_drop_sfx = [
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_1_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_2_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_3_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_4_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_5_v1.mp3")
]


@onready var item_pickup_sfx = [
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_1_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_2_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_3_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_4_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_5_v1.mp3")

]


#non 3D, looping
@onready var dread: AudioStreamPlayer = $music/dread
@onready var stressed: AudioStreamPlayer = $music/stressed
@onready var chillin: AudioStreamPlayer = $music/chillin

@onready var music_node: Node = $music
var music_players: Array[AudioStreamPlayer] = []
var music_stamps: PackedInt32Array = []
var newest_music_stamp: int = -1
var max_music_players: int = 3


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(max_spatial_one_shots):
		spatial_one_shots.append(AudioStreamPlayer3D.new())
		
	for i in range(max_music_players):
		var p := AudioStreamPlayer.new()
		music_players.append(p)
		music_stamps.append(-1)
		music_node.add_child(p)
		
	GameState.connect('state_changed', _on_state_change)
	_on_state_change(GameState.state)


func _on_state_change(s):
	if s == GameState.CHILLIN:
		toggle_chillin(true)
		toggle_stresed(false)
		toggle_dread(false)
	if s == GameState.STRESSED:
		toggle_chillin(false)
		toggle_stresed(true)
		toggle_dread(false)
	if s == GameState.DREAD:
		toggle_chillin(false)
		toggle_stresed(false)
		toggle_dread(true)


func toggle_chillin(b: bool):
	print('chillin:  ', b)
	if b:
		chillin.fade_in()
	else:
		chillin.fade_out()


func toggle_stresed(b: bool):
	print('toggle_stresed:  ', b)
	if b:
		stressed.fade_in()
	else:
		stressed.fade_out()


func toggle_dread(b: bool):
	print('toggle_dread:  ', b)
	if b:
		dread.fade_in()
	else:
		dread.fade_out()



func play_spatial_one_shot():
	pass


func play_sfx_from_array(arr:Array, volume:float = 0.0):
	play_sfx( get_rand(arr), volume )



func play_sfx(sound:AudioStreamMP3, volume:float = 0.0 ):
	var next_player: AudioStreamPlayer = null
	var next_player_index:int = 0
	
	var oldest_index_value: int = music_stamps[0]
	var oldest_index:int = 0
	for i in range(max_music_players):
		if !music_players[i].playing:
			next_player = music_players[i]
			next_player_index = i
			break
		else:
			if music_stamps[i] < oldest_index_value:
				oldest_index_value = music_stamps[i]
				oldest_index = i
	if !next_player:
		next_player = music_players[oldest_index]
		next_player_index = oldest_index
	newest_music_stamp += 1
	music_stamps[next_player_index] = newest_music_stamp
	next_player.stream = sound
	next_player.volume_db = volume
	next_player.play()


func play_music(song:String, volume:float = 0.0 ):
	if !music_node.has_node(song):
		return
	print('---------     play_music')
	var p = music_node.get_node(song)
	p.volume_db = volume
	p.fade_in()


func stop_music(song:String):
	print('---------     stop_music')
	if !music_node.has_node(song):
		return
	var p = music_node.get_node(song)
	p.fade_out()


#func fade_out(player, time := 4.0):
#	var tween = get_tree().create_tween()
#	tween.tween_property(player, "volume_db", -80, time)
#	await tween.finished
#	player.stop()


func get_rand(arr: Array):
	return arr[ randi_range( 0, len(arr)-1 ) ]

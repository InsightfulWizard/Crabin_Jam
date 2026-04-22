extends Node2D

@onready var sfx_node: Node2D = $sfx
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_stamps: PackedInt32Array = []
var newest_sfx_stamp: int = -1
var max_sfx_players: int = 10

@onready var item_drop_sfx = [
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_1_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_2_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_3_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_4_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Drop Sounds/Crabin Jam_Item Drop_5_v1.mp3"),
]

@onready var item_pickup_sfx = [
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_1_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_2_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_3_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_4_v1.mp3"),
	preload("res://audio/Sound/UI Sounds/Item Pickup Sounds/Crabin Jam_Item Pickup_5_v1.mp3"),
]

@onready var stutter = [
	preload("res://audio/Sound/Crab Stutters/Crabin Jam_2026_Stutter_1_v1.mp3"),
	preload("res://audio/Sound/Crab Stutters/Crabin Jam_2026_Stutter_2_v1.mp3"),
	preload("res://audio/Sound/Crab Stutters/Crabin Jam_2026_Stutter_3_v1.mp3"),
]

@onready var throat_clear = [
	preload("res://audio/Sound/Crab Throat Clears/Crabin Jam_Throat Clear_1_v1.mp3"),
	preload("res://audio/Sound/Crab Throat Clears/Crabin Jam_Throat Clear_2_v1.mp3"),
	preload("res://audio/Sound/Crab Throat Clears/Crabin Jam_Throat Clear_3_v1.mp3"),
	preload("res://audio/Sound/Crab Throat Clears/Crabin Jam_Throat Clear_4_v1.mp3"),
]

@onready var start_game = preload("res://audio/Sound/UI Sounds/Crabin Jam_2026_Start Game Menu Select_v1.mp3")

@onready var call_start = preload("res://audio/Sound/Friend Call Sounds/Crabin Jam_underwater friend call_start_1_v1.mp3")
@onready var call_end = preload("res://audio/Sound/Friend Call Sounds/Crabin Jam_underwater friend call_ending signal drop_1_v1.mp3")

#non 3D, looping
@onready var dread: AudioStreamPlayer = $music/dread
@onready var stressed: AudioStreamPlayer = $music/stressed
@onready var chillin: AudioStreamPlayer = $music/chillin

@onready var title: AudioStreamPlayer = $music/title

@onready var music_node: Node = $music


func fade_title():
	title.fade_out()


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	for i in range(max_sfx_players):
		var p := AudioStreamPlayer.new()
		sfx_players.append(p)
		sfx_stamps.append(-1)
		sfx_node.add_child(p)

	GameState.connect('state_changed', _on_state_change)
	#_on_state_change(GameState.state)


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
	if b:
		chillin.fade_in()
	else:
		chillin.fade_out()


func toggle_stresed(b: bool):
	if b:
		stressed.fade_in()
	else:
		stressed.fade_out()


func toggle_dread(b: bool):
	if b:
		dread.fade_in()
	else:
		dread.fade_out()


func play_spatial_one_shot():
	pass


func play_sfx_from_array(arr: Array, volume: float = 0.0):
	var a = play_sfx(get_rand(arr), volume)
	return a


func play_sfx(sound: AudioStreamMP3, volume: float = 0.0):
	var next_player: AudioStreamPlayer = null
	var next_player_index: int = 0

	var oldest_index_value: int = sfx_stamps[0]
	var oldest_index: int = 0
	for i in range(max_sfx_players):
		if !sfx_players[i].playing:
			next_player = sfx_players[i]
			next_player_index = i
			break
		else:
			if sfx_stamps[i] < oldest_index_value:
				oldest_index_value = sfx_stamps[i]
				oldest_index = i
	if !next_player:
		next_player = sfx_players[oldest_index]
		next_player_index = oldest_index
	newest_sfx_stamp += 1
	sfx_stamps[next_player_index] = newest_sfx_stamp
	next_player.stream = sound
	next_player.volume_db = volume
	next_player.play()
	return next_player


func play_music(song: String, volume: float = 0.0):
	if !music_node.has_node(song):
		return
	var p = music_node.get_node(song)
	p.volume_db = volume
	p.fade_in()


func stop_music(song: String):
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
	return arr[randi_range(0, len(arr) - 1)]

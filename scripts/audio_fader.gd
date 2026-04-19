extends AudioStreamPlayer


@export var start_low_volume: bool = true
var fade_tween: Tween

enum {
	OFF,
	FADE_IN,
	ON,
	FADE_OUT
}
var state := ON


func _ready():
	volume_db = -80
	state = OFF
	if !start_low_volume:
		fade_in()


func fade_in(time := 2.0):
	if state == ON or state == FADE_IN:
		return
	
	#print('---------     fade_in')
	state = FADE_IN
	if !playing:
		play()
	
	if fade_tween:
		fade_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(self, "volume_db", -6.0, time)
	await fade_tween.finished
	state = ON


func fade_out(time := 4.0):
	if state == OFF or state == FADE_OUT:
		return
	#print('---------     fade_out')
	state = FADE_OUT
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.set_trans(Tween.TRANS_QUAD)
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_property(self, "volume_db", -80, time)
	await fade_tween.finished
	stop()
	state = OFF

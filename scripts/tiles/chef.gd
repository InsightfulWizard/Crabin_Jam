extends Node2D

enum Mood {
	HAPPY,
	NEUTRAL,
	ANGRY
}

enum CharacterType {
	CHAR_1,
	CHAR_2,
	CHAR_3
}

@export var character_type: CharacterType = CharacterType.CHAR_1
@export var animated_sprite: AnimatedSprite2D
@export var switch_chance: float

var current_mood: Mood = Mood.NEUTRAL


func _ready() -> void:
	GameState.connect("score_changed", _on_score_changed)
	_on_score_changed(GameState.current_score)
	set_character(character_type)


func _on_score_changed(score: int) -> void:
	update_mood_from_score(score)


func update_mood_from_score(score: int) -> void:
	if GameState.state == GameState.CHILLIN:
		set_mood(Mood.HAPPY)
	if GameState.state == GameState.STRESSED:
		set_mood(Mood.NEUTRAL)
	if GameState.state == GameState.DREAD:
		set_mood(Mood.ANGRY)


func set_character(new_character: CharacterType) -> void:
	character_type = new_character
	play_current_animation()


func set_mood(new_mood: Mood) -> void:
	if current_mood == new_mood:
		return
		
	if randf() > switch_chance:
		return

	current_mood = new_mood
	play_current_animation()


func play_current_animation() -> void:
	var anim_name := "%s_%s" % [get_character_name(), get_mood_name()]

	if animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
	else:
		push_warning("Missing animation: " + anim_name)


func get_character_name() -> String:
	match character_type:
		CharacterType.CHAR_1:
			return "chef_1"
		CharacterType.CHAR_2:
			return "chef_2"
		CharacterType.CHAR_3:
			return "chef_3"
		_:
			return "chef_1"


func get_mood_name() -> String:
	match current_mood:
		Mood.HAPPY:
			return "happy"
		Mood.NEUTRAL:
			return "neutral"
		Mood.ANGRY:
			return "angry"
		_:
			return "neutral"

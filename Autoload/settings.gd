extends Node

signal game_cancelled
signal theme_changed

# TODO: Reconsider using dictionary instead of array
@export var color_schemes: Array[ColorScheme]

var highscore_location: String = "user://highscore.dat"
var settings_location: String = "user://settings.dat"

var circles_per_level: int = 5
var high_score: int

var theme: ColorScheme
var theme_name: String:
	set(value):
		theme_name = value
		update_theme()


func _ready() -> void:
	load_default_theme()
	load_high_score()
	load_settings()
	theme_changed.emit()


func load_default_theme() -> void:
	for color_scheme in color_schemes:
		if color_scheme.default:
			theme_name = color_scheme.name
			break


func update_theme() -> void:
	for color_scheme in color_schemes:
		if color_scheme.name == theme_name:
			theme = color_scheme
			theme_changed.emit()
			break


func get_weighted_random(weights: Array) -> int:
	var total_weight = 0
	for weight in weights:
		total_weight += weight

	var random_number: float = randf_range(0, total_weight)

	for i in range(weights.size()):
		if random_number < weights[i]:
			return i
		random_number -= weights[i]

	return 0


func save_high_score() -> void:
	var high_score_file = FileAccess.open(highscore_location, FileAccess.WRITE)
	high_score_file.store_line(str(high_score))


func load_high_score() -> void:
	var high_score_file = FileAccess.open(highscore_location, FileAccess.READ)
	if high_score_file:
		high_score = high_score_file.get_line().to_int()
	else:
		high_score = 0


func save_settings() -> void:
	var settings_file = FileAccess.open(settings_location, FileAccess.WRITE)
	var settings_dict: Dictionary = {
		"theme_name": theme_name,
		"music_enabled": AudioManager.is_music_enabled(),
		"sound_enabled": AudioManager.is_sound_enabled(),
		"enable_ads": false # TODO: Implement ads
	}

	var json_string = JSON.stringify(settings_dict)
	settings_file.store_string(json_string)


func load_settings() -> void:
	var settings_file = FileAccess.open(settings_location, FileAccess.READ)
	if not settings_file:
		return

	var settings_dict = JSON.parse_string(settings_file.get_as_text())

	theme_name = settings_dict["theme_name"]
	AudioManager.set_music_enabled(settings_dict["music_enabled"])
	AudioManager.set_sound_enabled(settings_dict["sound_enabled"])
	# TODO: Implement ads

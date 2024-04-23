extends Node

var highscore_location: String = "user://highscore.dat"
var settings_location: String = "user://settings.dat"
var themes_location: String = "res://Resources/Themes/"
var color_schemes: Dictionary

var circles_per_level: int = 5
var high_score: int

var theme: ColorScheme
var theme_name: String:
	set(value):
		theme_name = value
		theme = color_schemes[value]


func _ready() -> void:
	load_themes() # Iterate through files in theme directory and load them as color schemes
	load_high_score()
	load_settings()


func load_themes() -> void:
	var theme_dir = DirAccess.open(themes_location)

	if theme_dir:
		theme_dir.list_dir_begin()
		var file_name = theme_dir.get_next()
		while file_name != "":
			if not theme_dir.current_is_dir():
				var theme_resource = load(themes_location + file_name)
				if theme_resource is ColorScheme:
					color_schemes[theme_resource.name] = theme_resource
					if theme_resource.default:
						theme = theme_resource
						theme_name = theme_resource.name
			file_name = theme_dir.get_next()


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

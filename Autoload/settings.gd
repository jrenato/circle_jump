extends Node

var game_data_location: String = "user://gamedata.save"
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
	load_themes()
	load_game_data()
	

func load_themes() -> void:
	# Iterate through files in theme directory and load them as color schemes
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


func save_game_data() -> void:
	var game_data: Dictionary = {
		"high_score": high_score, 
		"theme_name": theme_name
	}

	var save_game = FileAccess.open(game_data_location, FileAccess.WRITE)
	var json_string = JSON.stringify(game_data)
	save_game.store_line(json_string)


func load_game_data() -> void:
	var save_game = FileAccess.open(game_data_location, FileAccess.READ)
	var json_string = save_game.get_line()
	var game_data = JSON.parse_string(json_string)
	
	high_score = game_data.get("high_score")
	theme_name = game_data.get("theme_name")

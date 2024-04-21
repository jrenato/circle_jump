extends Node

var color_schemes: Dictionary = {
	# "NEON1": preload("res://Resources/Themes/neon1.tres"),
	# "NEON2": preload("res://Resources/Themes/neon2.tres"),
	# "NEON3": preload("res://Resources/Themes/neon3.tres")
}

var theme_location: String = "res://Resources/Themes/"
var theme: ColorScheme

var circles_per_level: int = 5


func _ready() -> void:
	# Iterate through files in theme directory and load them as color schemes
	var theme_dir = DirAccess.open(theme_location)

	if theme_dir:
		theme_dir.list_dir_begin()
		var file_name = theme_dir.get_next()
		while file_name != "":
			if not theme_dir.current_is_dir():
				var theme_resource = load(theme_location + file_name)
				if theme_resource is ColorScheme:
					color_schemes[theme_resource.name] = theme_resource
					if theme_resource.default:
						theme = theme_resource
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

extends Node

var color_schemes: Dictionary = {
	"NEON1": preload("res://Resources/Themes/neon1.tres"),
	"NEON2": preload("res://Resources/Themes/neon2.tres"),
	"NEON3": preload("res://Resources/Themes/neon3.tres")
}

var circles_per_level: int = 5

var theme: ColorScheme = color_schemes["NEON2"]

extends Node2D

@export var circle_scene: PackedScene
@export var jumper_scene: PackedScene

var score: int :
	set(value):
		score = value
		update_score()

var jumper: Jumper
var level: int = 1

@onready var screens: CanvasLayer = %Screens
@onready var hud: Control = %HUD
@onready var start_position: Marker2D = %StartPosition
@onready var camera: Camera2D = %Camera2D


func _ready() -> void:
	randomize()
	screens.start_game.connect(new_game)

	hud.hide_hud()


func new_game() -> void:
	camera.position = start_position.position
	spawn_jumper()
	spawn_circle.call_deferred(start_position.position)

	hud.show_hud()
	hud.show_message("Go!")
	score = 0
	level = 1

	AudioManager.play_music("LightPuzzle")


func update_score() -> void:
	hud.update_score(score)
	if score > 0 and score % Settings.circles_per_level == 0:
		level += 1
		hud.show_message("Level %d" % level)


func spawn_jumper() -> void:
	jumper = jumper_scene.instantiate()
	add_child(jumper)
	jumper.position = start_position.position
	jumper.captured.connect(_on_jumper_captured)
	jumper.died.connect(_on_jumper_died)


func spawn_circle(circle_position: Variant = null, disable_points: bool = false) -> void:
	var circle: Circle = circle_scene.instantiate()
	add_child(circle)

	if disable_points:
		circle.points = 0

	if not circle_position:
		circle_position = jumper.target.position + Vector2(randi_range(-150, 150), randi_range(-500, -400))

	circle.init_circle(circle_position, level)


func _on_jumper_captured(target_area: Area2D) -> void:
	if not target_area is Circle:
		return

	score += target_area.points
	hud.update_score(score)

	var target_circle: Circle = target_area
	# Updated the camera position
	camera.position = target_circle.position
	# Animate the circle capture
	target_circle.capture(jumper)
	# Spawn next circle
	spawn_circle.call_deferred()


func _on_jumper_died() -> void:
	get_tree().call_group("circles", "implode")
	hud.hide_hud()
	screens.game_over()
	AudioManager.stop_music()

extends Node2D

@export var circle_scene: PackedScene
@export var jumper_scene: PackedScene

var score: int :
	set(value):
		score = value
		update_score()

var level: int

var jumper: Jumper

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
	spawn_circle(start_position.position, 100, Circle.MODE.STATIC, true)

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


func spawn_circle(_position: Vector2, _radius: int, _mode: Circle.MODE, _move_speed: float = 0.0, _move_range: int = 0, disable_points: bool = false) -> void:
	var circle: Circle = circle_scene.instantiate()
	add_child(circle)
	circle.position = _position
	circle.radius = _radius
	circle.mode = _mode
	circle.move_speed = _move_speed
	circle.move_range = _move_range

	if disable_points:
		circle.points = 0


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
	var next_circle_x: int = randi_range(-150, 150)
	var next_circle_y: int = randi_range(-500, -400)
	var next_circle_position: Vector2 = target_circle.position + Vector2(next_circle_x, next_circle_y)
	spawn_circle.call_deferred(next_circle_position, 100, Circle.MODE.LIMITED, 0.0, 0)


func _on_jumper_died() -> void:
	get_tree().call_group("circles", "implode")
	hud.hide_hud()
	screens.game_over()
	AudioManager.stop_music()

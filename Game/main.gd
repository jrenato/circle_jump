extends Node2D

@export var circle_scene: PackedScene
@export var jumper_scene: PackedScene

var jumper: Jumper

var score: int :
	set(value):
		score = value
		update_score()

var captured_circles: int = 0:
	set(value):
		captured_circles = value
		update_level()

var new_high_score: bool = false
var level: int = 1
var bonus: int = 1

@onready var screens: CanvasLayer = %Screens
@onready var hud: Control = %HUD
@onready var start_position: Marker2D = %StartPosition
@onready var camera: Camera2D = %Camera2D
@onready var background_rect: ColorRect = %BackgroundRect


func _ready() -> void:
	randomize()
	screens.start_game.connect(new_game)

	hud.hide_hud()

	background_rect.color = Settings.theme["background"]


func new_game() -> void:
	camera.position = start_position.position
	spawn_jumper()
	spawn_circle.call_deferred(start_position.position, true)

	hud.show_hud()
	hud.show_message("Go!")
	score = 0
	level = 1
	captured_circles = 0
	set_bonus(1)
	new_high_score = false

	AudioManager.music_volume = 1.0
	AudioManager.play_music("LightPuzzle")


func update_score() -> void:
	hud.update_score(score)

	if score > Settings.high_score and not new_high_score:
		hud.show_message("New Record!")
		new_high_score = true



func update_level() -> void:
	if captured_circles > 0 and captured_circles % Settings.circles_per_level == 0:
		level += 1
		hud.show_message("Level %d" % level)


func set_bonus(value: int) -> void:
	bonus = value
	hud.update_bonus(bonus)

func spawn_jumper() -> void:
	jumper = jumper_scene.instantiate()
	add_child(jumper)
	jumper.position = start_position.position
	jumper.captured.connect(_on_jumper_captured)
	jumper.died.connect(_on_jumper_died)


func spawn_circle(circle_position: Variant = null, disable_points: bool = false) -> void:
	var circle: Circle = circle_scene.instantiate()
	add_child(circle)

	circle.orbit_completed.connect(set_bonus.bind(1))

	if not circle_position:
		circle_position = jumper.target.position + Vector2(randi_range(-150, 150), randi_range(-500, -400))

	circle.init_circle(circle_position, level, disable_points)


func fade_music() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(AudioManager, "music_volume", 0.0, 1.0)
	await fade_tween.finished
	AudioManager.stop_music()


func _on_jumper_captured(target_area: Area2D) -> void:
	if not target_area is Circle:
		return

	var target_circle: Circle = target_area as Circle
	
	if not target_circle.silent_capture:
		score += bonus
		captured_circles += 1
		set_bonus(bonus + 1)

	# Updated the camera position
	camera.position = target_circle.position
	# Animate the circle capture
	target_circle.capture(jumper)
	# Spawn next circle
	spawn_circle.call_deferred()


func _on_jumper_died() -> void:
	get_tree().call_group("circles", "implode")
	hud.hide_hud()

	if score > Settings.high_score:
		Settings.high_score = score
		Settings.save_high_score()

	screens.game_over(score, Settings.high_score)

	fade_music()

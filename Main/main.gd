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
	spawn_circle.call_deferred(true)

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


func spawn_circle(first_circle: bool = false) -> void:
	var circle: Circle = circle_scene.instantiate()
	add_child(circle)

	circle.radius = 100

	if first_circle:
		circle.points = 0
		circle.position = start_position.position
		circle.mode = circle.MODE.STATIC
	else:
		circle.position = jumper.target.position + Vector2(randi_range(-150, 150), randi_range(-500, -400))

		var modes: Array = [circle.MODE.STATIC, circle.MODE.LIMITED]
		var weights: Array = [10, level-1]
		circle.mode = modes[Settings.get_weighted_random(weights)]

		var move_chance: float = clamp((level - 10), 0, 9) / 10.0
		if randf() < move_chance:
			circle.move_range = max(25, 100 * randf_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
			circle.move_speed = max(2.5 - ceil(level/5.0) * 0.25, 0.75)
			circle.start_movement()

		var small_chance = min(0.9, max(0, (level-10) / 20.0))
		if randf() < small_chance:
			circle.radius = max(50, circle.radius - level * randf_range(0.75, 1.25))


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

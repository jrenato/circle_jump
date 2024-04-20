extends Node2D

@export var circle_scene: PackedScene
@export var jumper_scene: PackedScene

var jumper: Jumper
var score: int

@onready var screens: CanvasLayer = %Screens
@onready var hud: Control = %HUD
@onready var start_position: Marker2D = %StartPosition
@onready var camera: Camera2D = %Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	screens.start_game.connect(new_game)

	hud.hide_hud()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func new_game() -> void:
	camera.position = start_position.position
	spawn_jumper()
	spawn_circle(start_position.position, Circle.MODE.STATIC, true)

	hud.show_hud()
	hud.show_message("Go!")
	score = 0
	hud.update_score(score)


func spawn_jumper() -> void:
	jumper = jumper_scene.instantiate()
	add_child(jumper)
	jumper.position = start_position.position
	jumper.captured.connect(_on_jumper_captured)
	jumper.died.connect(_on_jumper_died)


func spawn_circle(_position: Vector2, _mode: Circle.MODE, disable_points: bool = false) -> void:
	var circle: Circle = circle_scene.instantiate()
	add_child(circle)
	circle.position = _position
	circle.mode = _mode

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
	spawn_circle.call_deferred(next_circle_position, Circle.MODE.LIMITED)


func _on_jumper_died() -> void:
	get_tree().call_group("circles", "implode")
	hud.hide_hud()
	screens.game_over()

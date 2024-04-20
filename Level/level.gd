extends Node2D

@export var circle_scene: PackedScene
@export var jumper_scene: PackedScene

var player: Jumper

@onready var start_position: Marker2D = %StartPosition
@onready var camera: Camera2D = %Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func new_game() -> void:
	camera.position = start_position.position
	player = jumper_scene.instantiate()
	player.position = start_position.position
	add_child(player)
	player.captured.connect(_on_jumper_captured)
	spawn_circle(start_position.position)


func spawn_circle(_position: Vector2) -> void:
	var circle: Circle = circle_scene.instantiate()
	circle.position = _position
	add_child(circle)
	circle.init(circle.position)


func _on_jumper_captured(target_area: Area2D) -> void:
	if not target_area is Circle:
		return

	var target_circle: Circle = target_area
	
	# Updated the camera position
	camera.position = target_circle.position

	# Animate the circle capture
	target_circle.capture(player)

	# Spawn next circle
	var next_circle_x: int = randi_range(-150, 150)
	var next_circle_y: int = randi_range(-500, -400)
	var next_circle_position: Vector2 = target_circle.position + Vector2(next_circle_x, next_circle_y)
	spawn_circle.call_deferred(next_circle_position)

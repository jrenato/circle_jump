extends Node2D

@export var circle_scene: PackedScene
var font = preload("res://Assets/Fonts/Xolonium-Regular.ttf")
var level
var last_circle_position
var level_markers = []


func _ready():
	randomize()
	last_circle_position = $Camera2D.position
	level = 0
	for i in 150:
		if i % 5 == 0:
			level += 1
			level_markers.append(last_circle_position)
		spawn_circle()
	queue_redraw()


func _process(delta):
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= 15
	if Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += 15
	if Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= 15
	if Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += 15


func spawn_circle(_position=null):
	var c = circle_scene.instantiate()
	if !_position:
		var x = randi_range(-150, 150)
		var y = randi_range(-500, -400)
		_position = last_circle_position + Vector2(x, y)
	add_child(c)
	c.init_circle(_position, level)
	last_circle_position = _position


func _draw():
	var level_string: int = 1
	for pos in level_markers:
		var start_position = Vector2(pos.x-480, pos.y-200)
		var end_position = Vector2(pos.x-80, pos.y-200)
		draw_line(start_position, end_position, Color(1, 1, 1), 15)
		draw_string(
			font, start_position - Vector2(0, 50), str(level_string),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 64
		)
		level_string += 1

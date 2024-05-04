class_name Jumper extends Area2D

signal captured(area: Area2D)
signal died

var velocity: Vector2 = Vector2(100, 0)
var jump_speed: int = 1000
var target: Circle = null:
	set(value):
		target = value
		is_trail_emitting = target == null

var is_trail_emitting: bool = false
var trail_length: int = 30
var trail_points: Array[Vector2]
var blank_trail: Array[Vector2]

@onready var sprite: Sprite2D = %Sprite2D
@onready var trail_line: Line2D = %TrailLine2D
@onready var off_screen_timer: Timer = %OffScreenTimer


func _ready() -> void:
	Settings.game_cancelled.connect(die)
	Settings.theme_changed.connect(_on_theme_changed)

	update_theme()


func update_theme() -> void:
	sprite.material.set_shader_parameter("color", Settings.theme["player_body"])
	var trail_color: Color = Settings.theme["player_trail"]
	trail_line.gradient.set_color(0, trail_color)
	trail_color.a = 0
	trail_line.gradient.set_color(1, trail_color)


func _process(delta: float) -> void:
	if is_trail_emitting:
		trail_points.push_front(position)
	else:
		if trail_points.size() > 0:
			blank_trail.push_front(position)

	if trail_points.size() + blank_trail.size() > trail_length:
		if trail_points.size() > 0:
			trail_points.pop_back()
		elif blank_trail.size() > 0:
			blank_trail.pop_back()

	trail_line.clear_points()
	
	for point in trail_points:
		trail_line.add_point(point)


func _physics_process(delta: float) -> void:
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta


func  _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if target and event.is_pressed():
			jump()


func jump() -> void:
	target.implode()
	target = null
	velocity = transform.x * jump_speed
	trail_points.clear()
	blank_trail.clear()

	AudioManager.play_sound("Jump")


func die() -> void:
	died.emit()
	target = null
	queue_free()


func _on_game_cancelled() -> void:
	die()


func _on_area_entered(area: Area2D) -> void:
	if area is Circle:
		target = area as Circle
		velocity = Vector2.ZERO
		captured.emit(area)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not target and off_screen_timer.is_stopped():
		off_screen_timer.start()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	off_screen_timer.stop()


func _on_theme_changed() -> void:
	update_theme()


func _on_off_screen_timer_timeout() -> void:
	if not target:
		die()

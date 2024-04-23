class_name Jumper extends Area2D

signal captured(area: Area2D)
signal died

var velocity: Vector2 = Vector2(100, 0)
var jump_speed: int = 1000
var target: Circle = null
var trail_length: int = 25

@onready var trail = %Points
@onready var sprite: Sprite2D = %Sprite2D


func _ready() -> void:
	sprite.material.set_shader_parameter("color", Settings.theme["player_body"])
	var trail_color: Color = Settings.theme["player_trail"]
	trail.gradient.set_color(1, trail_color)
	trail_color.a = 0
	trail.gradient.set_color(0, trail_color)


func _process(delta) -> void:
	pass


func _physics_process(delta: float) -> void:
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta

	# Updated trail points
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if target and event.is_pressed():
			jump()


func jump() -> void:
	target.implode()
	target = null
	velocity = transform.x * jump_speed

	AudioManager.play_sound("Jump")


func die() -> void:
	died.emit()
	target = null
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area is Circle:
		target = area as Circle
		velocity = Vector2.ZERO
		captured.emit(area)
		AudioManager.play_sound("Capture")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not target:
		die()

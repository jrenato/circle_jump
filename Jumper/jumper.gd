class_name Jumper extends Area2D

signal captured(area: Area2D)

var velocity: Vector2 = Vector2(100, 0)
var jump_speed: int = 1000
var target: Node2D = null


func _ready() -> void:
	pass


func _process(delta) -> void:
	pass


func _physics_process(delta: float) -> void:
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if target:
			jump()


func jump() -> void:
	target = null
	velocity = transform.x * jump_speed


func _on_area_entered(area: Area2D) -> void:
	target = area
	velocity = Vector2.ZERO
	captured.emit(area)

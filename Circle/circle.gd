class_name Circle extends Area2D

var radius: int = 100
var rotation_speed: float = PI

@onready var pivot: Node2D = %Pivot
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var sprite_effect = %SpriteEffect
@onready var orbit_position: Marker2D = %OrbitPosition
@onready var animation_player = %AnimationPlayer


func _ready() -> void:
	sprite_effect.visible = false


func init(_position: Vector2, _radius: int = radius):
	position = _position
	radius = _radius
	rotation_speed *= pow(-1, randi() % 2)

	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.radius = radius
	var img_size: float = sprite.texture.get_size().x / 2.0
	sprite.scale = Vector2(1, 1) * radius / img_size
	orbit_position.position.x = radius + 25


func _process(delta: float) -> void:
	pivot.rotation += rotation_speed * delta


func capture() -> void:
	animation_player.play("capture")


func implode() -> void:
	if !animation_player.is_playing():
		animation_player.play("implode")
	await animation_player.animation_finished
	queue_free()

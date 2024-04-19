class_name Circle extends Area2D

var radius: int = 100
var rotation_speed: float = PI

@onready var pivot: Node2D = %Pivot
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var orbit_position: Marker2D = %OrbitPosition


func _ready() -> void:
	init()


func init(_radius=radius):
	radius = _radius
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.radius = radius
	var img_size = sprite.texture.get_size().x / 2
	sprite.scale = Vector2(1, 1) * radius / img_size
	orbit_position.position.x = radius + 25


func _process(delta: float) -> void:
	pivot.rotation += rotation_speed * delta

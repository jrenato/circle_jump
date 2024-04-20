class_name Circle extends Area2D

enum MODE {STATIC, LIMITED}

var jumper: Jumper = null

var mode: MODE = MODE.STATIC
var max_orbits: int = 3 # Number of orbits until the circle disappears
var orbits_left: int = 0 # Number of orbits the jumper has completed
var orbit_start: float = 0.0 # The angle where the orbit started

var radius: int = 100
var rotation_speed: float = PI

@onready var pivot: Node2D = %Pivot
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var sprite_effect = %SpriteEffect
@onready var orbit_position: Marker2D = %OrbitPosition
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var orbits_label: Label = %OrbitsLabel


func _ready() -> void:
	sprite_effect.visible = false


func init(_position: Vector2, _radius: int = radius, _mode=MODE.LIMITED):
	position = _position
	radius = _radius
	update_mode(_mode)
	rotation_speed *= pow(-1, randi() % 2)

	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.radius = radius
	var img_size: float = sprite.texture.get_size().x / 2.0
	sprite.scale = Vector2(1, 1) * radius / img_size
	orbit_position.position.x = radius + 25


func _process(delta: float) -> void:
	pivot.rotation += rotation_speed * delta
	if mode == MODE.LIMITED and jumper:
		check_orbits()


func update_mode(_mode: MODE) -> void:
	mode = _mode
	match mode:
		MODE.STATIC:
			orbits_label.hide()
		MODE.LIMITED:
			orbits_left = max_orbits
			orbits_label.text = str(orbits_left)
			orbits_label.show()


func check_orbits() -> void:
	if abs(pivot.rotation - orbit_start) >= 2 * PI:
		orbits_left -= 1
		orbits_label.text = str(orbits_left)

		if orbits_left <= 0:
			jumper.die()
			jumper = null
			implode()

		orbit_start = pivot.rotation


func capture(player: Jumper) -> void:
	jumper = player
	animation_player.play("capture")
	pivot.rotation = (jumper.position - position).angle()
	orbit_start = pivot.rotation


func implode() -> void:
	if !animation_player.is_playing():
		animation_player.play("implode")
	await animation_player.animation_finished
	queue_free()

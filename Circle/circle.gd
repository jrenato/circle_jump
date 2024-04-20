class_name Circle extends Area2D

enum MODE {STATIC, LIMITED}

var jumper: Jumper = null

var mode: MODE = MODE.STATIC:
	set(value):
		mode = value
		update_mode()

var radius: int = 100:
	set(value):
		radius = value
		update_radius()

var rotation_speed: float = PI:
	set(value):
		rotation_speed = value
		if rotation_speed >= 0:
			orbit_progress_bar.fill_mode = TextureProgressBar.FillMode.FILL_CLOCKWISE
		else:
			orbit_progress_bar.fill_mode = TextureProgressBar.FillMode.FILL_COUNTER_CLOCKWISE

 # The angle where the orbit started
var orbit_start: float = 0.0:
	set(value):
		orbit_start = value
		orbit_progress_bar.radial_initial_angle = rad_to_deg(orbit_start + PI/2)

var max_orbits: int = 3 # Number of orbits until the circle disappears
var orbits_left: int = 0 # Number of orbits the jumper has completed

var points: int = 1

@onready var pivot: Node2D = %Pivot
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var sprite: Sprite2D = %Sprite2D
@onready var sprite_effect = %SpriteEffect
@onready var orbit_position: Marker2D = %OrbitPosition
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var orbits_label: Label = %OrbitsLabel
@onready var orbit_progress_bar: TextureProgressBar = %OrbitProgressBar


func _ready() -> void:
	sprite_effect.visible = false
	radius = 100

	rotation_speed *= pow(-1, randi() % 2)


func _process(delta: float) -> void:
	pivot.rotation += rotation_speed * delta
	if mode == MODE.LIMITED and jumper:
		check_orbits()
		update_ui()


func update_radius() -> void:
	collision_shape.shape = collision_shape.shape.duplicate()
	collision_shape.shape.radius = radius
	var img_size: float = sprite.texture.get_size().x / 2.0
	sprite.scale = Vector2(1, 1) * radius / img_size
	orbit_progress_bar.scale = sprite.scale / 2.0
	orbit_position.position.x = radius + 25


func update_mode() -> void:
	match mode:
		MODE.STATIC:
			orbits_label.hide()
			orbit_progress_bar.hide()
		MODE.LIMITED:
			orbits_left = max_orbits
			orbits_label.text = str(orbits_left)
			orbits_label.show()
			orbit_progress_bar.hide()


func check_orbits() -> void:
	if abs(pivot.rotation - orbit_start) >= 2 * PI:
		orbits_left -= 1

		AudioManager.play_sound("Beep")

		if orbits_left <= 0:
			jumper.die()
			jumper = null
			implode()

		orbit_start = pivot.rotation


func update_ui() -> void:
	if orbits_label.text != str(orbits_left):
		orbits_label.text = str(orbits_left)
	orbit_progress_bar.value = abs(pivot.rotation - orbit_start) / (2 * PI)


func capture(player: Jumper) -> void:
	jumper = player
	animation_player.play("capture")
	pivot.rotation = (jumper.position - position).angle()
	orbit_start = pivot.rotation
	if mode == MODE.LIMITED:
		orbit_progress_bar.show()


func implode() -> void:
	if !animation_player.is_playing():
		animation_player.play("implode")
	await animation_player.animation_finished
	queue_free()

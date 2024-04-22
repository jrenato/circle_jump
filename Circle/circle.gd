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

var move_range: float = 0.0 # How far the circle can move. Zero means it won't move
var move_speed: float = 1.0 # How fast the circle moves

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

	# Update the theme
	sprite.material = sprite.material.duplicate()
	sprite_effect.material = sprite.material
	orbit_progress_bar.tint_progress = Settings.theme["circle_fill"]

	# Randomize the orbit direction
	rotation_speed *= pow(-1, randi() % 2)


func init_circle(circle_position: Vector2, level: int) -> void:
	position = circle_position
	radius = 100

	var modes: Array = [MODE.STATIC, MODE.LIMITED]
	var weights: Array = [10, level-1]
	mode = modes[Settings.get_weighted_random(weights)]

	var move_chance: float = clamp((level - 10), 0, 9) / 10.0
	if randf() < move_chance:
		move_range = max(25, 100 * randf_range(0.75, 1.25) * move_chance) * pow(-1, randi() % 2)
		move_speed = max(2.5 - ceil(level/5.0) * 0.25, 0.75)
		start_movement()

	var small_chance = min(0.9, max(0, (level-10) / 20.0))
	if randf() < small_chance:
		radius = max(50, radius - level * randf_range(0.75, 1.25))


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
	var color: Color

	match mode:
		MODE.STATIC:
			orbits_label.hide()
			orbit_progress_bar.hide()
			color = Settings.theme["circle_static"]
		MODE.LIMITED:
			orbits_left = max_orbits
			orbits_label.text = str(orbits_left)
			orbits_label.show()
			orbit_progress_bar.hide()
			color = Settings.theme["circle_limited"]
	sprite.material.set_shader_parameter("color", color)
	sprite_effect.material.set_shader_parameter("color", color)


func start_movement() -> void:
	if move_range == 0:
		return

	var move_tween: Tween = create_tween().set_loops()\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN_OUT)
	move_tween.tween_property(self, "position:x", position.x + move_range, move_speed)
	move_tween.tween_property(self, "position:x", position.x, move_speed)


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

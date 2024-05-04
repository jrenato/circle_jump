extends Node2D

@export var circle_scene: PackedScene
@export var jumper_scene: PackedScene

var jumper: Jumper
var resume_countdown: int

@onready var resume_timer: Timer = %ResumeTimer


var score: int :
	set(new_score):
		set_score(score, new_score)
		score = new_score

var captured_circles: int = 0:
	set(value):
		captured_circles = value
		set_level()

var bonus: int = 1:
	set(value):
		# If bonus > 1 && value == 1, it means the
		# bonus was downgraded (reset)
		hud.update_bonus(value, bonus > 1 && value == 1)
		bonus = value

var new_high_score: bool = false
var level: int = 1:
	set(value):
		level = value
		hud.update_level(level)
		if level > 1:
			hud.show_message(tr("LEVEL").format({"level": level}))


@onready var screens: CanvasLayer = %Screens
@onready var hud: Control = %HUD
@onready var start_position: Marker2D = %StartPosition
@onready var camera: Camera2D = %Camera2D
@onready var background_rect: ColorRect = %BackgroundRect
@onready var pause_rect: ColorRect = %PauseRect


func _ready() -> void:
	randomize()
	screens.start_game.connect(new_game)
	Settings.theme_changed.connect(_on_theme_changed)

	update_theme()

	hud.pause_resume_game.connect(_on_pause_resume_game)
	hud.hide_hud()
	pause_rect.visible = false


func update_theme() -> void:
	background_rect.color = Settings.theme["background"]


func new_game() -> void:
	camera.position = start_position.position
	spawn_jumper()
	spawn_circle.call_deferred(start_position.position, true)

	hud.show_hud()
	hud.show_message("GO")
	score = 0
	bonus = 1
	level = 1
	captured_circles = 0
	new_high_score = false

	pause_rect.visible = false

	AudioManager.music_volume = 1.0
	AudioManager.play_music("LightPuzzle")
	Settings.load_interstitial_ad()


func set_score(current_score: int, new_score: int) -> void:
	hud.update_score(current_score, new_score)

	if new_score > Settings.high_score and not new_high_score:
		hud.show_message("NEW_RECORD")
		new_high_score = true



func set_level() -> void:
	if captured_circles > 0 and captured_circles % Settings.circles_per_level == 0:
		level += 1
		


func spawn_jumper() -> void:
	jumper = jumper_scene.instantiate()
	add_child(jumper)
	jumper.position = start_position.position
	jumper.captured.connect(_on_jumper_captured)
	jumper.died.connect(_on_jumper_died)


func spawn_circle(circle_position: Variant = null, disable_points: bool = false) -> void:
	var circle: Circle = circle_scene.instantiate()
	add_child(circle)

	circle.orbit_completed.connect(func(): bonus = clampi(floori(bonus / 2.0), 1, bonus))

	if not circle_position:
		circle_position = jumper.target.position + Vector2(randi_range(-150, 150), randi_range(-500, -400))

	circle.init_circle(circle_position, level, disable_points)


func fade_music() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(AudioManager, "music_volume", 0.0, 1.0)
	await fade_tween.finished
	AudioManager.stop_music()


func _on_jumper_captured(target_area: Area2D) -> void:
	if not target_area is Circle:
		return

	var target_circle: Circle = target_area as Circle
	
	if not target_circle.silent_capture:
		score += bonus
		captured_circles += 1
		bonus += 1

	# Updated the camera position
	camera.position = target_circle.position
	# Animate the circle capture
	target_circle.capture(jumper)
	# Spawn next circle
	spawn_circle.call_deferred()


func _on_jumper_died() -> void:
	get_tree().call_group("circles", "implode")
	hud.hide_hud()

	fade_music()
	pause_rect.visible = false

	if score > Settings.high_score:
		Settings.high_score = score
		Settings.save_high_score()

	screens.game_over(score, Settings.high_score)

	score = 0
	level = 1
	bonus = 1


func _on_pause_resume_game() -> void:
	if get_tree().paused:
		pause_rect.visible = false
		# Set resume countdown
		resume_countdown = 3
		_on_resume_timer_timeout()
	else:
		pause_rect.visible = true
	screens.pause_resume_game()


func _on_theme_changed() -> void:
	update_theme()


func _on_resume_timer_timeout() -> void:
	if resume_countdown > 0:
		# Update resume countdown
		hud.show_message(str(resume_countdown))
		resume_countdown -= 1
		resume_timer.start()
	else:
		# Unpause the game
		get_tree().paused = false

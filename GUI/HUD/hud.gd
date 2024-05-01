extends Control

signal pause_resume_game

@export var pause_texture: Texture2D
@export var resume_texture: Texture2D

var score: int:
	set(value):
		score = value
		score_tween_step(value)

var score_tween: Tween

# Containers
@onready var bonus_container: VBoxContainer = %BonusVBoxContainer
@onready var score_container: VBoxContainer = %ScoreVBoxContainer
@onready var level_container: VBoxContainer = %LevelVBoxContainer
# Labels
@onready var score_label: Label = %ScoreLabel
@onready var bonus_label: Label = %BonusLabel
@onready var level_label: Label = %LevelLabel
@onready var message_label: Label = %MessageLabel
# Buttons
@onready var pause_resume_button: TextureButton = %PauseResumeButton
# Animation Players
@onready var bonus_animation_player: AnimationPlayer = %BonusAnimationPlayer
@onready var score_animation_player: AnimationPlayer = %ScoreAnimationPlayer
@onready var message_animation_player: AnimationPlayer = %MessageAnimationPlayer


func show_message(text: String) -> void:
	message_label.text = text
	message_label.pivot_offset = message_label.size / 2

	if message_animation_player.is_playing():
		await message_animation_player.animation_finished
	message_animation_player.play("show_message")


func update_score(current_score: int, added_score: int) -> void:
	score = current_score

	if added_score == 0:
		return

	if score_animation_player.is_playing():
		score_animation_player.stop()
	score_animation_player.play("score_up")

	if score_tween:
		score_tween.kill()
	score_tween = create_tween()
	score_tween.tween_property(self, "score", added_score, 0.25)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)


func score_tween_step(value: int):
	score_label.text = str(value)


func update_bonus(bonus: int, downgraded: bool = false) -> void:
	bonus_label.text = "%s x" % str(bonus)

	if bonus_animation_player.is_playing():
		await bonus_animation_player.animation_finished

	if bonus > 1:
		bonus_animation_player.play("bonus_up")
	elif downgraded:
		bonus_animation_player.play("bonus_down")


func update_level(level: int) -> void:
	level_label.text = str(level)


func hide_hud() -> void:
	bonus_container.hide()
	score_container.hide()
	level_container.hide()
	pause_resume_button.hide()


func show_hud() -> void:
	bonus_container.show()
	score_container.show()
	level_container.show()
	pause_resume_button.show()


func _on_pause_resume_button_pressed() -> void:
	if get_tree().paused:
		pause_resume_button.texture_normal = pause_texture
	else:
		pause_resume_button.texture_normal = resume_texture
	pause_resume_game.emit()

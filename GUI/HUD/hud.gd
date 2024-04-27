extends Control

var score: int:
	set(value):
		score = value
		score_tween_step(value)

var score_tween: Tween

@onready var score_name_label: Label = $HBoxContainer/ScoreNameLabel
@onready var score_label: Label = %ScoreLabel
@onready var bonus_label: Label = %BonusLabel
@onready var message_label: Label = %Message
@onready var bonus_animation_player: AnimationPlayer = %BonusAnimationPlayer
@onready var score_animation_player: AnimationPlayer = %ScoreAnimationPlayer
@onready var message_animation_player: AnimationPlayer = %MessageAnimationPlayer


func show_message(text: String) -> void:
	if message_animation_player.is_playing():
		await message_animation_player.animation_finished
	message_label.text = text
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


func hide_hud() -> void:
	score_name_label.hide()
	score_label.hide()
	bonus_label.hide()


func show_hud() -> void:
	score_label.show()
	score_name_label.show()
	bonus_label.show()

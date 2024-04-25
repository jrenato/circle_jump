extends Control

var score: int:
	set(value):
		score = value
		tween_step(value)

var score_tween: Tween

@onready var score_box: MarginContainer = %ScoreBox
@onready var score_label: Label = %ScoreLabel
@onready var bonus_label: Label = %BonusLabel
@onready var message_label: Label = %Message
@onready var message_animation_player: AnimationPlayer = %MessageAnimationPlayer
@onready var bonus_animation_player: AnimationPlayer = %BonusAnimationPlayer


func show_message(text: String) -> void:
	if message_animation_player.is_playing():
		await message_animation_player.animation_finished
	message_label.text = text
	message_animation_player.play("show_message")


func update_score(current_score: int, added_score: int) -> void:
	score = current_score
	if score_tween:
		score_tween.kill()
	score_tween = create_tween()
	score_tween.tween_property(self, "score", added_score, 0.25)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)


func tween_step(value: int):
	score_label.text = str(value)


func update_bonus(bonus: int) -> void:
	bonus_label.text = "%s x" % str(bonus)
	if bonus > 1:
		if bonus_animation_player.is_playing():
			await bonus_animation_player.animation_finished
		bonus_animation_player.play("bonus")


func hide_hud() -> void:
	score_box.hide()
	bonus_label.hide()


func show_hud() -> void:
	score_box.show()
	bonus_label.show()

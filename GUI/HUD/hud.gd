extends Control

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


func update_score(score: int) -> void:
	score_label.text = str(score)


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

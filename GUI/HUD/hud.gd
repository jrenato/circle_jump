extends Control

@onready var score_box: MarginContainer = %ScoreBox
@onready var score_label: Label = %ScoreLabel
@onready var bonus_label: Label = %BonusLabel
@onready var message_label: Label = %Message
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func show_message(text: String) -> void:
	if animation_player.is_playing():
		animation_player.stop()
	message_label.text = text
	animation_player.play("show_message")


func update_score(score: int) -> void:
	score_label.text = str(score)


func update_bonus(bonus: int) -> void:
	bonus_label.text = "%s x" % str(bonus)
	if bonus > 1:
		animation_player.play("bonus")


func hide_hud() -> void:
	score_box.hide()
	bonus_label.hide()


func show_hud() -> void:
	score_box.show()
	bonus_label.show()

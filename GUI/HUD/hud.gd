extends Control

@onready var score_box: MarginContainer = %ScoreBox
@onready var score_label: Label = %Score
@onready var message_label: Label = %Message
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func show_message(text: String) -> void:
	message_label.text = text
	animation_player.play("show_message")


func update_score(score: int) -> void:
	score_label.text = str(score)


func hide_hud() -> void:
	score_box.hide()


func show_hud() -> void:
	score_box.show()

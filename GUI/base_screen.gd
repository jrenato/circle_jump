class_name BaseScreen extends Control

@export var score_label: Label
@export var highscore_label: Label
@export var about_label: RichTextLabel
@export var music_label: Label
@export var sound_label: Label
@export var theme_label: Label

var fadeout_duration: float = 0.5


func _ready() -> void:
	position.x = 500
	if about_label:
		about_label.text = "[center]Copyright © 2024 Karvalho

[url=https://github.com/jrenato/circle_jump]%s[/url]

[url=https://github.com/jrenato/circle_jump/blob/master/LICENSE]%s[/url]
[/center]" % [tr("SOURCE_CODE"), tr("LICENSE_INFO")]


func appear() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position:x", 0, fadeout_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN_OUT)
	return tween


func disappear() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "position:x", 500, fadeout_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN_OUT)
	return tween


func _on_about_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
